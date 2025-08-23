# frozen_string_literal: true

require "sqlite3"

module JekyllSQlite
  # Main generator class
  class Generator < Jekyll::Generator
    # Set to high to be higher than the Jekyll Datapages Plugin
    priority :high

    ##
    # Recursively attach query results to nested data structures
    # Supports arbitrary levels of nesting (e.g., regions.territories.EmployeeIDs)
    # Handles both arrays and hashes at each level
    def attach_nested_data(root, path_segments, db, query)
      return 0 if path_segments.empty?

      if path_segments.size == 1
        key = path_segments.first
        db.prepare(query) do |stmt|
          _prepare_query(stmt, get_bind_params(root))
          root[key] = stmt.execute.to_a
        end
        return root[key].size
      end

      first, *remaining = path_segments
      current_level = root[first]

      if current_level.is_a?(Array)
        current_level.sum { |item| attach_nested_data(item, remaining, db, query) }
      else
        attach_nested_data(current_level, remaining, db, query)
      end
    end

    ##
    # Prepare the query by binding the parameters
    # Since we don't know if the query needs them
    # we ignore all errors about "no such bind parameter"
    def _prepare_query(stmt, params)
      params.each do |key, value|
        stmt.bind_param key, value
      rescue StandardError => e
        raise e unless e.message.include? "no such bind parameter"
      end
    end

    ##
    # Validate given configuration object
    def valid_config?(config)
      return false unless config.is_a? Hash
      return false unless config.key?("query")
      return false unless File.exist?(config["file"])
      return false unless config.key?("data")

      true
    end

    ## pick bindable parameters
    # from the root
    # All primitive values are bound to the query
    # Arrays and Hashes are ignored
    def get_bind_params(dict)
      dict.select { |_key, value| !value.is_a?(Array) && !value.is_a?(Hash) }
    end

    def generate_data_from_config(root, config)
      key = config["data"]
      query = config["query"]
      file = config["file"]
      SQLite3::Database.new file, readonly: true do |db|
        db.results_as_hash = config.fetch("results_as_hash", true)

        path_segments = key.split(".")
        count = attach_nested_data(root, path_segments, db, query)
        Jekyll.logger.info "Jekyll SQLite:", "Loaded #{key}. Count=#{count}"
      end
    end

    ##
    # Generate the data from the configuration
    # Takes as input the root where the data will be attached
    # and a configuration holder, where the sqlite key can be found
    # Root is either site.data or page.data
    # and config_holder is either site.config or page itself.
    def gen(root, config_holder)
      sqlite_configs = config_holder["sqlite"] || []
      sqlite_configs.each do |config|
        unless valid_config?(config)
          Jekyll.logger.error "Jekyll SQLite:", "Invalid Configuration. Skipping"
          next
        end
        generate_data_from_config(root, config)
      end
    end

    ##
    # Entrpoint to the generator, called by Jekyll
    def generate(site)
      gen(site.data, site.config)
      site.pages.each do |page|
        gen(page.data, page)
      end
    end
  end
end

# frozen_string_literal: true

require "sqlite3"

module JekyllSQlite
  # Main generator class
  class Generator < Jekyll::Generator
    # Set to high to be higher than the Jekyll Datapages Plugin
    priority :high

    ##
    # Split the given key using dots and return the last part
    #   customers.order -> order
    def get_tip(name)
      name.split(".")[-1]
    end

    ##
    # Get the root of where we are generating the data
    def get_root(root, db_name)
      db_name.split(".")[0..-2].each do |p|
        root = root[p]
      rescue KeyError
        raise "Jekyll SQLite: Invalid root. #{p} not found while iterating to #{db_name}"
      end
      root
    end

    ##
    # Prepare the query by binding the parameters
    # from the root
    # All primitive values are bound to the query
    # Arrays and Hashes are ignored
    # Since we don't know if the query needs them
    # we ignore all errors about "no such bind parameter"
    def _prepare_query(stmt, root)
      root.each do |key, value|
        next if value.is_a?(Array) || value.is_a?(Hash)

        begin
          stmt.bind_param key, value
        rescue StandardError => e
          raise e unless e.message.include? "no such bind parameter"
        end
      end
    end

    ##
    # Internal function to generate data given
    # root: a Hash-Like root object (site.data, site.data.*, page.data)
    # query: string containing the query to execute
    # db_name: string as the key to use to attach the data to the root
    # db: SQLite3 Database object to execute the query on
    # Sets root[db_name] = ResultSet of the query, as an array
    def _gen_data(root, query, db_name, db)
      db.prepare(query) do |stmt|
        _prepare_query stmt, root
        root[db_name] = stmt.execute.to_a
      end
      root[db_name].count
    end

    ##
    # Calls _gen_data for the given root
    # iterates through the array if root is an array
    def gen_data(root, ...)
      if root.nil? || (root.is_a? Hash)
        _gen_data(root, ...)
      elsif root.is_a? Array
        # call gen_data for each item in the array
        # and return the sum of all the counts
        root.map { |item| gen_data(item, ...) }.sum
      end
    end

    ##
    # Validate given configuration object
    def validate_config(config)
      return false unless config.is_a? Hash
      return false unless config.key?("query")
      return false unless File.exist?(config["file"])
      return false unless config.key?("data")

      true
    end

    ##
    # Given a configuration, generate the data
    # and attach it to the given data_root
    def generate_data_from_config(data_root, config)
      d_name = config["data"]
      SQLite3::Database.new config["file"], readonly: true do |db|
        db.results_as_hash = config.fetch("results_as_hash", true)
        branch = get_root(data_root, d_name)
        get_tip(d_name)
        count = gen_data(branch, config["query"], get_tip(d_name), db)
        Jekyll.logger.info "Jekyll SQLite:", "Loaded #{d_name}. Count=#{count}"
      end
    end

    ##
    # Iterate through all the pages in the site
    # and generate the data from the configuration
    def gen_pages(site)
      site.pages.each do |page|
        gen(page.data, page)
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
        unless validate_config(config)
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
      gen_pages(site)
    end
  end
end

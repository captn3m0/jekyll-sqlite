# frozen_string_literal: true

require "sqlite3"
require "time"

module JekyllSQlite
  # Main generator class
  # rubocop:disable Metrics/ClassLength
  class Generator < Jekyll::Generator
    # Set to high to be higher than the Jekyll Datapages Plugin
    priority :high

    def get_database(file)
      return @db[file] if @db.key?(file)

      @db[file] = SQLite3::Database.new file, readonly: true
    end

    def close_all_databases
      @db.each_value(&:close)
    end

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
      stmt.named_params.each do |key|
        val = params[key]
        unless [Integer, String, Float, SQLite3::Blob, nil].include? val.class
          Jekyll.logger.error "#{key} type is #{val.class} in query: #{stmt.get_sql}"
        end
        stmt.bind_param key, params[key]
      end
    end

    ##
    # Validate given configuration object.
    # A config is valid when it is a Hash with a query, a readable file,
    # and either a data: or collection: target.
    def valid_config?(config)
      return false unless config.is_a? Hash
      return false unless config.key?("query")
      return false unless config["file"] && File.exist?(config["file"])
      return false unless config.key?("data") || config.key?("collection")

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

      db = get_database(file)
      db.results_as_hash = config.fetch("results_as_hash", true)
      path_segments = key.split(".")
      count = attach_nested_data(root, path_segments, db, query)
      Jekyll.logger.info "Jekyll SQLite:", "Loaded #{key}. Count=#{count}"
    end

    ##
    # Generate the data from the configuration
    # Takes as input the root where the data will be attached
    # and a configuration holder, where the sqlite key can be found
    # Root is either site.data or page.data
    # and config_holder is either site.config or page itself.
    def gen(root, config_holder)
      (config_holder["sqlite"] || []).each do |config|
        unless valid_config?(config)
          Jekyll.logger.error "Jekyll SQLite:", "Invalid Configuration. Skipping"
          next
        end

        if config["collection"]
          generate_collection_from_config(config)
        else
          generate_data_from_config(root, config)
        end
      end
    end

    ##
    # Build documents from query rows and append them to the named site collection.
    def generate_collection_from_config(config)
      name = config["collection"]
      collection = @site.collections[name]
      unless collection
        Jekyll.logger.error "Jekyll SQLite:", "Collection '#{name}' not declared in _config.yml"
        return
      end

      db = get_database(config["file"])
      db.results_as_hash = config.fetch("results_as_hash", true)
      rows = db.execute(config["query"])
      rows.each_with_index { |row, idx| collection.docs << build_collection_doc(collection, row, idx) }
      Jekyll.logger.info "Jekyll SQLite:", "Loaded collection #{name}. Count=#{rows.size}"
    end

    # Build a synthetic document path from optional `name` and `path` columns.
    # Falls back to a 1-based row id (idx+1) when `name` is missing, and to
    # no subdirectory when `path` is missing. The `name` and `path` SQL
    # columns are what feed Jekyll's :name and :path permalink placeholders.
    def synth_doc_path(collection, row, idx)
      name = column_string(row, "name") || (idx + 1).to_s
      subdir = column_string(row, "path")
      parts = ["_#{collection.label}"]
      parts << subdir if subdir
      parts << "#{name}.md"
      File.join(@site.source, *parts)
    end

    def build_collection_doc(collection, row, idx)
      doc = Jekyll::Document.new(synth_doc_path(collection, row, idx),
                                 site: @site, collection: collection)
      row.each do |k, v|
        next unless k.is_a?(String)

        v = Time.parse(v) if k == "date" && v.is_a?(String)
        doc.data[k] = v
      end
      # Jekyll's :title permalink placeholder reads data["slug"], not data["title"].
      # Auto-populate slug from title so SQL-provided titles show up in URLs.
      doc.data["slug"] ||= doc.data["title"]
      doc.content = row.key?("content") ? row["content"].to_s : ""
      doc
    end

    def column_string(row, key)
      v = row[key]
      v.is_a?(String) && !v.empty? ? v : nil
    end

    ##
    # Entrpoint to the generator, called by Jekyll
    def generate(site)
      @db = {}
      @site = site
      gen(site.data, site.config)
      site.pages.each do |page|
        gen(page.data, page)
      end
    ensure
      close_all_databases
    end
  end
  # rubocop:enable Metrics/ClassLength
end

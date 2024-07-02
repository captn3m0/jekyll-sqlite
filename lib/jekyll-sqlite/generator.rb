# frozen_string_literal: true
require "sqlite3"

module JekyllSQlite
  # Main generator class
  class Generator < Jekyll::Generator
    safe true
    # Set to high to be higher than the Jekyll Datapages Plugin
    priority :high
    # Default pragma
    def fast_setup(db)
      db.execute("PRAGMA synchronous = OFF")
      db.execute("PRAGMA journal_mode = OFF")
      db.execute("PRAGMA query_only = ON")
    end

    # Get the root of where we are generating the data
    def get_root(root, db_name)
      db_name.split(".")[0..-2].each do |p|
        root = root[p]
      end
      root
    end

    def gen_hash_data(root, db, db_name, query)
      root ||= {}

      root[db_name] = db.execute(query)
      root[db_name].size
    end

    def gen_nested_data(item, db, query, db_name)
      item[db_name] = []
      db.prepare(query) do |stmt|
        # We bind params, ignoring any errors
        # Since there's no way to get required params
        # From a statement
        item.each do |key, value|
          stmt.bind_param key, value
        rescue StandardError # rubocop:disable Lint/SuppressedException
        end
        stmt.execute.each { |d| item[db_name] << d }
      end
      item[db_name].size
    end

    def array_gen(root, config, db_name, db)
      count = 0
      root.each do |item|
        # TODO: Add support for binding Arrays as well.
        if item.is_a? Hash
          count += gen_nested_data(item, db, config["query"], db_name)
        else
          Jekyll.logger.info "Jekyll SQLite:", "Item is not a hash for #{db_name}. Unsupported configuration"
        end
      end
      count
    end

    def gen_data(root, config, db_name, db)
      count = 0
      if root.nil? || (root.is_a? Hash)
        count = gen_hash_data(root, db, db_name, config["query"])
      elsif root.is_a? Array
        count = array_gen(root, config, db_name, db)
      end
      count
    end

    def get_tip(name)
      name.split(".")[-1]
    end

    def validate_config(config)
      return false unless config.is_a? Hash
      return false unless config.key?("query")
      return false unless File.exist?(config["file"])
      return false unless config.key?("data")
      true
    end

    def generate(site)
      gem_config = site.config['sqlite'] || []
      gem_config.each do |config|
        unless validate_config(config)
          Jekyll.logger.error "Jekyll SQLite:", "Invalid Configuration. Skipping"
          next
        end
        d_name = config["data"]
        SQLite3::Database.new config["file"], readonly: true do |db|
          fast_setup db
          db.results_as_hash = config.fetch("results_as_hash", true)
          root = get_root(site.data, d_name)
          count = gen_data(root, config, get_tip(d_name), db)
          Jekyll.logger.info "Jekyll SQLite:", "Loaded #{d_name}. Count=#{count}"
        end
      end
    end
  end
end

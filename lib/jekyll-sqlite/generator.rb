# frozen_string_literal: true
require 'sqlite3'
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
    def get_root(root, name)
      name.split(".")[0..-2].each do |p|
        root = root[p]
      end
      root
    end

    def gen_hash_data(root, db, query, name)
      root ||= {}

      root[name] = db.execute(query)
      root[name].size
    end

    def gen_nested_data(item, db, query, name)
      item[name] = []
      db.prepare(query) do |stmt|
        # We bind params, ignoring any errors
        # Since there's no way to get required params
        # From a statement
        item.each do |key, value|
          stmt.bind_param key, value
        rescue StandardError # rubocop:disable Lint/SuppressedException
        end
        stmt.execute.each { |d| item[name] << d }
      end
      item[name].size
    end

    def array_gen(root, config, name, db)
      count = 0
      root.each do |item|
        # TODO: Add support for binding Arrays as well.
        if item.is_a? Hash
          count += gen_nested_data(item, db, config["query"], name)
        else
          Jekyll.logger.info "Jekyll SQLite:", "Item is not a hash for #{name}. Unsupported configuration"
        end
      end
      count
    end

    def gen_data(root, config, name, db)
      count = 0
      if root.nil? || (root.is_a? Hash)
        count = gen_hash_data(root, db, config["query"], name)
      elsif root.is_a? Array
        count = array_gen(root, config, name, db)
      end
      count
    end

    def get_tip(name)
      name.split(".")[-1]
    end

    def generate(site)
      data = site.config["sqlite"]
      if data
        data.each do |config|
          name = config["data"]
          SQLite3::Database.new config["file"], readonly: true do |db|
            fast_setup db
            db.results_as_hash = config.fetch("results_as_hash", true)
            root = get_root(site.data, name)
            count = gen_data(root, config, get_tip(name), db)
            Jekyll.logger.info "Jekyll SQLite:", "Loaded #{name}. Count=#{count}. as_hash=#{db.results_as_hash}"
          end
        end
      end
    end
  end
end

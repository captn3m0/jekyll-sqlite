# frozen_string_literal: true

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

    def generate(site)
      site.config["sqlite"].each do |name, config|
        SQLite3::Database.new config["file"], readonly: true do |db|
          Jekyll.logger.info "Jekyll SQLite:", "Starting to load #{name}"
          fast_setup db
          db.results_as_hash = config.fetch("results_as_hash", true)
          site.data[name] = db.execute(config["query"])
          Jekyll.logger.info "Jekyll SQLite:", "Loaded #{name}. Count=#{site.data[name].size}"
        end
      end
    end
  end
end

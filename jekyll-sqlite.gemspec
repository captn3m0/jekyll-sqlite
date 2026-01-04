# frozen_string_literal: true

require_relative "lib/jekyll-sqlite/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-sqlite"
  spec.license = "MIT"
  spec.version = Jekyll::Sqlite::VERSION
  spec.authors = ["Nemo"]
  spec.email = ["jekyll-sqlite@captnemo.in"]

  spec.summary = "A Jekyll plugin to use SQLite databases as a data source."
  spec.homepage = "https://captnemo.in/jekyll-sqlite/"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/captn3m0/jekyll-sqlite/"
  spec.metadata["changelog_uri"] = "https://captnemo.in/jekyll-sqlite/CHANGELOG.html"

  spec.files = [
    "lib/jekyll-sqlite/generator.rb",
    "lib/jekyll-sqlite/version.rb",
    "lib/jekyll_sqlite.rb",
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "Gemfile"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "sqlite3", "~> 2.9.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end

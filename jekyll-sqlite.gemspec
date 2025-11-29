# frozen_string_literal: true

require_relative "lib/jekyll-sqlite/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-sqlite"
  spec.license = "MIT"
  spec.version = Jekyll::Sqlite::VERSION
  spec.authors = ["Nemo"]
  spec.email = ["jekyll-sqlite@captnemo.in"]

  spec.summary = "A Jekyll plugin to use SQLite databases as a data source."
  spec.homepage = "https://github.com/captn3m0/jekyll-sqlite"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/captn3m0/jekyll-sqlite/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "sqlite3", "~> 2.9.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end

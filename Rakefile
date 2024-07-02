# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"
require "jekyll"
require "sqlite3"

RuboCop::RakeTask.new

def assert(cond, msg = "Assertion Failed")
  raise msg unless cond
end

def query_db(query)
  db = SQLite3::Database.new "_db/northwind.db"
  db.results_as_hash = true
  results = db.execute query
  results[0]
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def validate_json
  file = "_site/data.json"
  data = JSON.parse(File.read(file))
  assert data["orders"].size == 53, "Expected 53 orders, got #{data["orders"].size}"
  assert data["customers"].size == 93, "Expected 93 customers, got #{data["customers"].size}"
  assert data["categories"].size == 8, "Expected 93 categories, got #{data["categories"].size}"
  assert data["orders"][0] == query_db("SELECT * FROM Orders LIMIT 1"), "Order Fetch Failed"
  assert data["customers"][0] == query_db("SELECT * FROM Customers LIMIT 1"), "Customer Fetch Failed"
  assert data["customers"][0] == query_db("SELECT * FROM Customers LIMIT 1"), "Customer Fetch Failed"
  assert data["categories"][0]["products"].size == 12, "Products don't match"
  data["categories"][0]["products"].each do |p|
    assert p["CategoryID"] == 1, "CategoryID doesn't match"
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength

task default: :rubocop

desc "Build Test Site"
task :test do
  Dir.chdir("test")
  Jekyll::Site.new(Jekyll.configuration).process
  validate_json
end

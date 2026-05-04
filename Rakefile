# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"


RuboCop::RakeTask.new

def assert(cond, msg = "Assertion Failed")
  raise msg unless cond
end

def query_db(query)
  require "sqlite3"
  db = SQLite3::Database.new "_db/northwind.db"
  db.results_as_hash = true
  results = db.execute query
  results[0]
end

# rubocop:disable Metrics/AbcSize
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
  assert data["delayedOrders"].size == 17
  assert data["delayedOrders"][0]["OrderID"] == 10_249
end

def validate_page_json
  file = "_site/suppliers.json"
  read_data = JSON.parse(File.read(file))
  data = read_data["allSuppliers"]
  assert data.size == 29, "Expected 29 suppliers, got #{data.size}"
  r = query_db("SELECT CompanyName, SupplierID FROM Suppliers ORDER BY SupplierID LIMIT 1")
  assert r["CompanyName"] == data[0]["CompanyName"], "Company Name doesn't match"
  assert r["SupplierID"] == data[0]["SupplierID"], "Supplier ID doesn't match"
  assert data[0]["products"].size == 3, "Products don't match"
  assert data[0]["products"][0]["ProductName"] == "Chai"
  assert data[0]["products"][1]["ProductName"] == "Chang"
  assert data[0]["products"][2]["ProductName"] == "Aniseed Syrup"

  # Focus Supplier - this uses the data from the page front-matter to prepare a query
  fs = query_db("SELECT * FROM Suppliers WHERE SupplierID = 6")
  assert read_data["focusSupplier"][0] == fs, "Focus Supplier doesn't match"
end

def validate_employees_json
  file = "_site/employees.json"
  regions = JSON.parse(File.read(file))
  assert regions.size == 4
  assert regions[0]["RegionID"] == 1, "First RegionID should be 1"
  assert regions[0]["RegionDescription"] == "Eastern", "First Region is Eastern"
  assert regions[-1]["RegionID"] == 4, "Four zotal Regions"
  assert regions[0]["territories"].size == 19, "There should be 19 territories in Eastern"
  assert regions[0]["territories"][0]["TerritoryID"] == "01730", "First TerritoryID should be 1"
  assert regions[0]["territories"][0]["TerritoryDescription"] == "Bedford", "First TerritoryID should be Bedford"
  bedford = regions[0]["territories"][0]
  assert bedford == {
    "TerritoryID" => "01730",
    "TerritoryDescription" => "Bedford",
    "EmployeeIDs" => [{ "EmployeeID" => 2, "FirstName" => "Andrew", "LastName" => "Fuller" }]
  }, "Bedford should have Andrew Fuller"
end

def validate_collections_json
  data = JSON.parse(File.read("_site/collections.json"))

  # ---- site.posts: file post + SQL-appended posts coexist (no overwrite) ----
  posts = data["posts"]
  assert data["postsCount"] == 6, "Expected 6 posts (1 file + 5 SQL), got #{data["postsCount"]}"
  assert posts.size == 6, "Expected 6 post entries"

  # File-based post in _posts/ must survive after the SQL plugin runs.
  hello = posts.find { |p| p["title"] == "Hello World" }
  assert hello, "File post 'Hello World' missing from site.posts"
  assert hello["date"] == "2016-07-01", "hello-world date mismatch: #{hello["date"]}"
  assert File.exist?("_site/2016/07/01/hello-world.html"),
         "Expected file post output at /2016/07/01/hello-world.html"

  # Jekyll forces output:true on the posts collection, so SQL posts also render.
  sql = posts.find { |p| p["OrderID"] == 10_252 }
  assert sql, "SQL post OrderID 10252 missing"
  assert sql["title"] == "Order 10252", "SQL post title mismatch"
  assert sql["CustomerID"] == "SUPRD", "SQL post CustomerID mismatch"
  assert sql["ShipName"] == "Suprêmes délices", "SQL post ShipName mismatch"
  assert sql["date"] == "2016-07-09", "SQL post date mismatch"
  assert File.exist?("_site/2016/07/09/Order-10252.html"),
         "Expected SQL post rendered at /2016/07/09/Order-10252.html"

  # ---- site.shippers: output:true, per-row SQL-driven permalink, Markdown rendering ----
  shippers = data["shippers"]
  assert data["shippersCount"] == 3, "Expected 3 shippers"
  assert shippers.size == 3
  expected_company = { 1 => "Speedy Express", 2 => "United Package", 3 => "Federal Shipping" }
  expected_html = {
    1 => "<p>We are <em>very</em> Speedy</p>",
    2 => "<p>Uniting your packages <em>with you</em>.</p>",
    3 => "<ul>\n  <li>We are better than the others</li>\n  <li>Not kidding.</li>\n</ul>"
  }
  shippers.each do |s|
    id = s["ShipperID"]
    assert s["CompanyName"] == expected_company[id], "shipper #{id} CompanyName mismatch"
    expected = "/shippers/#{id}.html"
    assert s["permalink"] == expected, "permalink #{s["permalink"]} != #{expected}"
    assert s["url"] == expected, "url #{s["url"]} != #{expected}"
    file = "_site/shippers/#{id}.html"
    assert File.exist?(file), "Expected output file #{file}"
    body = File.read(file)
    assert body.include?(expected_html[id]),
           "Expected rendered Markdown for shipper #{id} in #{file}, got #{body.inspect}"
  end

  # ---- site.shipper_pages: output:true, common permalink template ----
  # Markdown rendering already verified on shippers; here we only assert that
  # Jekyll resolves /:path/:name-:title:output_ext from SQL columns.
  pages = data["shipperPages"]
  assert data["shipperPagesCount"] == 3, "Expected 3 shipper_pages"
  assert pages.size == 3
  expected_urls = {
    1 => "/companies/shipper-1/shipper-1-Speedy-Express.html",
    2 => "/companies/shipper-2/shipper-2-United-Package.html",
    3 => "/companies/shipper-3/shipper-3-Federal-Shipping.html"
  }
  pages.each do |p|
    want = expected_urls[p["ShipperID"]]
    assert p["url"] == want, "shipper_pages url #{p["url"]} != #{want}"
    assert File.exist?("_site#{want}"), "Expected output file _site#{want}"
  end
end
# rubocop:enable Metrics/AbcSize
task default: :rubocop

desc "Build Test Site"
task :test do
  require "jekyll"
  Dir.chdir("test")
  Jekyll::Site.new(Jekyll.configuration).process
  validate_json
  validate_page_json
  validate_employees_json
  validate_collections_json
end

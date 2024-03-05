require "jekyll_sqlite"

SITE = {
  "config" => {
    "data" => {},
    "sqlite" => [
      {
        "data" => "products",
        "file" => "test/northwind.db",
        "query" => "SELECT * FROM Products"
      },
      {
        "data" => "products.orders",
        "file" => "test/northwind.db",
        "query" => 'SELECT * FROM "Order Details" WHERE ProductID=:ProductID'
      },
      {
        "data" => "products.orders.details",
        "file" => "test/northwind.db",
        "query" => 'SELECT * FROM "Orders" WHERE OrderID=:OrderID'
      },
      {
        "data" => "categories",
        "file" => "test/northwind.db",
        "query" => "SELECT * FROM Categories",
        "results_as_hash" => false
      },
      {
        "data" => "categories.products",
        "file" => "test/northwind.db",
        "query" => "SELECT * FROM Products WHERE CategoryID = :CategoryID",
        "results_as_hash" => false
      }
    ]
  }
}

class NorthwindTest < Minitest::Test
  def test_northwind
    Jekyll::Site.new
    g = JekyllSQlite::Generator.new
    g.generate(SITE)
  end
end

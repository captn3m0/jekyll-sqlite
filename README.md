# Jekyll SQLite plugin

A Jekyll generator plugin to lets you use SQLite database instead of data files as a data source. It lets you easily create APIs and websites from a SQLite database, by linking together a database file, your template, and the relevant queries.

It supports site-level queries, per-page queries, and prepared queries that can
use existing data (possibly generated via more queries) as parameters.

[![Continuous Integration](https://github.com/captn3m0/jekyll-sqlite/actions/workflows/main.yml/badge.svg)](https://github.com/captn3m0/jekyll-sqlite/actions/workflows/main.yml) [![Gem Version](https://badge.fury.io/rb/jekyll-sqlite.svg)](https://badge.fury.io/rb/jekyll-sqlite)

## Installation

Add this line to your site's `Gemfile`:

```ruby
gem 'jekyll-sqlite'
```

And then add this line to your site's `_config.yml`:

```yml
plugins:
  - jekyll_sqlite
```

## Usage

🏁 A fully-functional demo website that uses this plugin is available at
[northwind.captnemo.in](https://northwind.captnemo.in). The source code for
the demo is available at [captn3m0/northwind](https://github.com/captn3m0/northwind).

Update your `_config.yml` to define your data sources with your SQLite database.

```yml
...
sqlite:
  - data: customers
    file: *db
    query: SELECT * from Customers
```

Then, you can use the `site.data` attributes accordingly:

```liquid
{{ site.data.customers | jsonify }}
```

## Prepared Queries

This plugin supports prepared queries with parameter binding. This lets you
use existing data from a previous query, or some other source (such as
`site.data.*` or `page.*`) as a parameter in your query.

Say you have a YAML file defining your items (`data/books.yaml`):

```yaml
- id: 31323952-2708-42dc-a995-6006a23cbf00
  name: Time Travel with a Rubber Band
- id: 5c8e67a0-d490-4743-b5b8-8e67bd1f95a2
  name: The Art of Cache Invalidation
```
and the prices for the items in your SQLite database, the following configuration will enrich the `items` array with the price:

```yaml
sql:
- data: items.books
  query: SELECT price, author FROM pricing WHERE id =:id
  db: books.db
```
This would allow the following Liquid loop to be written:

```liquid
{% for item in site.data.items %}
{{item.meta.price}}, {{item.meta.author}}
{% endfor %}
```

## Per Page Queries

The exact same syntax can be used on a per-page basis to generate data within
each page. This is helpful for keeping page-specific queries within the page
itself. Here's an example:

```yaml
---
FeaturedSupplierID: 2
sqlite:
  - data: suppliers
    file: "_db/northwind.db"
    query: "SELECT CompanyName, SupplierID FROM suppliers ORDER BY SupplierID"
  - data: suppliers.products
    # This is a prepared query, where SupplierID is coming from the previous query.
    file: "_db/northwind.db"
    query: "SELECT ProductName, CategoryID,UnitPrice FROM products WHERE SupplierID = :SupplierID"
  # :FeaturedSupplierID is picked up automatically from the page frontmatter.
  - data: FeaturedSupplier
    file: "_db/northwind.db"
    query: "SELECT * SupplierID = :FeaturedSupplierID"
---
{{page.suppliers|jsonify}}
```

This will generate a `page.suppliers` array with all the suppliers, and a `page.FeaturedSupplier` object with the details of the featured supplier.

Each supplier will have a `products` array with all the products for that supplier.

## Generating Pages

It works well with the `datapage_gen` plugin:

See the [datapage_gen](https://github.com/avillafiorita/jekyll-datapage_gen) docs for more details.

Here's a sample configuration:

```yaml
sqlite:
  restaurants:
    file: _db/reviews.db
    sql: SELECT id, name, last_review_date > 1672531200 as active, address FROM restaurants;
page_gen:
  - data: restaurants
    template: restaurant
    name: id
    title: name
    filter: active
```

This will automatically generate a file for each restaurant
restaurants/#{id}.html file with the layout `_layouts/restaurant.html` and page.id, page.name, page.active set and page.title set to restaurant name

Note that the `datapage_gen` plugin will run _after_ the `jekyll-sqlite` plugin,
if you generate any pages with per-page queries, these queries will not execute.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/captn3m0/jekyll-sqlite. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

Note that only maintained versions of [Jekyll](https://endoflife.date/jekyll) and
[Ruby](https://endoflife.date/ruby) are supported.

## Code of Conduct

Everyone interacting in the Jekyll::Sqlite project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

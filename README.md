# Jekyll SQLite plugin

A Jekyll generator plugin to lets you use SQLite database instead of data files as a data source. It lets you easily create APIs and websites from a SQLite database, by linking together a database file, your template, and the relevant queries.

It additionally supports nested queries, so that you can use the rows of `site.data.items` as bind_params for your nested query.

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

:warning: If you are using Jekyll < 3.5.0 use the `gems` key instead of `plugins`.

## Usage

Update your `_config.yml` to define your data sources with your SQLite database.

```yml
...
# These are run in sequence, so any nested data can work well.
sqlite:
  - data: members
    file: _db/users.db
    query: SELECT * FROM members ORDER by created_at DESC
  # You can use `results_as_hash` to switch between array or hash results (default).
  - data: verified
    results_as_hash: false # default true
    file: _db/users.db
    query: SELECT username, email FROM members WHERE verified=1
  - data: members.posts
    file: _db/posts.db
    query: SELECT * FROM posts WHERE user_id = :id
```

Then, you can use the `site.data` attributes accordingly:

```liquid
{% for member in site.data.members %}
- {{member.username}}

  # Your Posts
  {% for post in member.posts %}
    {{post}}
  {% endfor %}
{% endfor %}

# Result here is an array instead of a hash.
{% for user in site.data.verified %}
- :check: {{user[0]}} (Email: {{user[1]}})
{% endfor %}
```

## Generating Pages

It works well with the `datapage_gen` plugin:

See the [datapage_gen](https://github.com/avillafiorita/jekyll-datapage_gen) docs for more details.

Here's a sample configuration:

```yaml
# This will automatically generate a file for each restaurant
# restaurants/#{id}.html file
# with the layout `_layouts/restaurant.html`
# and page.id, page.name, page.active set
# and page.title set to restaurant name
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

## Nested Queries

You can use the rows of `site.data.items` as bind_params for your nested query. For this to work against
data generated by the plugin, the configuration order must be correct, so you need `site.data.items` above `site.data.items.nested` in your configuration.

Say you have a YAML file defining your items (`data/items.yaml`):

```yaml
- id: 31323952-2708-42dc-a995-6006a23cbf00
  name: Item 1
- id: 5c8e67a0-d490-4743-b5b8-8e67bd1f95a2
  name: Item 2
```
and the prices for the items in your SQLite database, the following configuration will enrich the `items` array with the price:

```yaml
sql:
- data: site.data.items.meta
  query: SELECT price,author FROM pricing WHERE id =:id
```
This would allow the following Liquid loop to be written:

```liquid
{% for item in site.data.items %}
{{item.meta.price}}, {{item.meta.author}}
{% endfor %}
```

This works well with `results_as_configuration` as well.

```yaml
sql:
- data: site.data.items.meta
  query: SELECT price,author FROM pricing WHERE id =:id
  results_as_hash: false
```

The following also renders the price and author:

```liquid
{% for item in site.data.items %}
  {{item.meta[0]}}, {{item.meta[1]}}
{% endfor %}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/captn3m0/jekyll-sqlite. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Jekyll::Sqlite project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

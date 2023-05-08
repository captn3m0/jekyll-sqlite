# Jekyll SQLite plugin

A Jekyll generator plugin to lets you use SQLite database instead of data files as a data source.

[![Continuous Integration](https://github.com/captn3m0/jekyll-sqlite/actions/workflows/main.yml/badge.svg)](https://github.com/captn3m0/jekyll-sqlite/actions/workflows/main.yml) [![Gem Version](https://badge.fury.io/rb/jekyll-sqlite.svg)](https://badge.fury.io/rb/jekyll-sqlite)

## Installation

Add this line to your site's Gemfile:

```ruby
gem 'jekyll-sqlite'
```

And then add this line to your site's `_config.yml`:

```yml
plugins:
  - jekyll-sqlite
```

:warning: If you are using Jekyll < 3.5.0 use the `gems` key instead of `plugins`.

## Usage

Update your `_config.yml` to define your data sources with your SQLite database.

```yml
...
sqlite:
  members:
    file: _db/users.db
    sql: SELECT * FROM members ORDER by created_at DESC
  # You can use `results_as_hash` to switch between array or hash results (default).
  verified:
    results_as_hash: false # default true
    file: _db/users.db
    sql: SELECT username, email FROM members WHERE verified=1
```

Then, you can use the `site.data` attributes accordingly:

```liquid
{% for user in site.data.members %}
- {{user.username}}
{% endfor %}

# Result here is an array instead of a hash.
{% for user in site.data.verified %}
- :check: {{user[0]}} (Email: {{user[1]}})
{% endfor %}
```

It works well with the datapage_gen plugin:

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/captn3m0/jekyll-sqlite. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Jekyll::Sqlite project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

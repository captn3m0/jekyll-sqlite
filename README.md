# Jekyll SQlite plugin

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


## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/captn3m0/jekyll-sqlite. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Jekyll::Sqlite project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/captn3m0/jekyll-sqlite/blob/main/CODE_OF_CONDUCT.md).

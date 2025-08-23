---
title: Contribution Guide
---

# Contributing to jekyll-sqlite

**This document is a work-in-progress.**

This doc is a short introduction on how to modify and maintain the sqlite3-ruby gem.

## Making a Release

0. Update `version.rb`
0. Update CHANGELOG.md
1. Run `bundle exec rake rubocop` to lint
2. Commit + push
3. If build passes, tag and push the tag.

Gem publication on rubygems automatically happens via GitHub Actions. 

## Running Tests

`bundle exec rake test`

## Test Infrastructure

The tests are maintained in `test` directory as a separate jekyll website.
The site is built inside `Rakefile`, and it uses JSON output files as templates.

These JSON output files can then be used for testing the plugin.

## Rubocop

Linting is mandatory to pass the CI.

## Docs

Docs are maintained in docs/ directory as a separate Jekyll site that uses
just-the-docs theme. A few markdown files are symlinked inside docs so that
they get published to the website as well.

## Demo

The demo is maintained separately on another repo, but the expectation is that
all important features are used in the demo. If you contribute such a change
that adds a new feature, please update the demo as well.
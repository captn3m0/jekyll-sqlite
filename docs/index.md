---
title: Home
nav_order: 0
---

A Jekyll generator plugin to lets you use SQLite database instead of data files as a data source. It lets you easily create APIs and websites from a SQLite database, by linking together a database file, your template, and the relevant queries.

It supports site-level queries, per-page queries, and prepared queries that can
use existing data (possibly generated via more queries) as parameters.

The primary usecase is to **avoid Liquid Hell**, wherein you're left mangling
multiple data sources from CSV/JSON/YAML files using liquid templating by
saving temporary variables, creating maps, and so on. SQL is a decent language
for reshaping datasets - supporting joins, filters, and aggregations. So this
allows you to use SQL for reshaping your data, and then use liquid
for what it was meant for - presentation and templating.

[![Continuous Integration](https://github.com/captn3m0/jekyll-sqlite/actions/workflows/main.yml/badge.svg)](https://github.com/captn3m0/jekyll-sqlite/actions/workflows/main.yml) [![Gem Version](https://badge.fury.io/rb/jekyll-sqlite.svg)](https://badge.fury.io/rb/jekyll-sqlite)
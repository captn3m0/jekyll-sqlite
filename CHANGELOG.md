---
title: Changelog
nav_order: "ZZZ"
---

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-08-23
- Multiple-levels of nesting is now supported
- Slight performance improvement by keeping database open for entire plugin run

## [0.1.6] - 2025-07-31
- Drop Ruby 3.1
- sqlite3 requirement to `2.7.3`

## [0.1.5] - 2024-07-31
- sqlite3 requirement changed to `1.6`

## [0.1.4] - 2024-07-17
- Per-page queries are now supported via a `sqlite` config block in the front matter.
- Documents support for existing site data being used within queries.
- Code cleanup and refactoring.
- Don't disable journaling on the database.

## [0.1.3] - 2024-07-02
- First functional version
- Adds tests

## [0.1.0] - 2023-05-08

- Initial release

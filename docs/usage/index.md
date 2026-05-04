---
title: Usage
has_toc: false
permalink: /usage/
---
Update your `_config.yml` to define your data sources with your SQLite database.

```yml
...
sqlite:
  - data: customers
    file: *db
    query: SELECT * from Customers
```

Then, you can use the `site.data` attributes accordingly:

```liquid{%raw%}
{{ site.data.customers | jsonify }}{%endraw%}
```

## Output targets

A query can write to one of two targets:

- **`data:`** — attaches results to `site.data` (or `page.data` for [per-page queries]({% link usage/per-page.md %})). Use this when the data is consumed by your own templates.
- **`collection:`** — appends results as documents to a Jekyll [collection](https://jekyllrb.com/docs/collections/), including the special built-in `posts` collection. Use this when you want each row to become a page, or when you want existing Jekyll plugins (pagination, feed, sitemap, categories) to pick up the data automatically.

See [Writing to Collections]({% link usage/collections.md %}) for the collection form.

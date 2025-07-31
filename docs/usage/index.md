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
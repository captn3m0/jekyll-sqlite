---
title: Parametrized Queries
parent: Usage
nav_order: 1
---
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
  file: books.db
  query: SELECT price, author FROM pricing WHERE id =:id
```
This would allow the following Liquid loop to be written:

```liquid{%raw%}
{% for item in site.data.items %}
{{item.meta.price}}, {{item.meta.author}}
{% endfor %}{%endraw%}
```
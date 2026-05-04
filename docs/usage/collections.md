---
title: Writing to Collections
parent: Usage
nav_order: 5
---

Instead of writing query results to `site.data`, you can write them as
documents into a Jekyll [collection](https://jekyllrb.com/docs/collections/).
This makes each row behave like a regular document — it gets a `url`, can
render through a layout, and is picked up by other Jekyll plugins.

Use the `collection:` key in place of `data:`:

```yaml
collections:
  shippers:
    output: true
    permalink: /shippers/:name/

sqlite:
  - collection: shippers
    file: _db/northwind.db
    query: SELECT ShipperID, CompanyName, Phone FROM Shippers
```

Each row becomes a document in `site.shippers`. Columns are merged into the
document's front-matter, so a template can reference `shipper.CompanyName`,
`shipper.Phone`, and so on.

A `content` column, if present in the query, is used as the document body
and is processed through Jekyll's normal converter chain — so Markdown in
the column renders to HTML on output.

## Permalinks

Two ways to control where each row is published:

### Per-row permalink (one URL per row)

Add a `permalink` column to your query. The value sets that document's
permalink directly:

```yaml
sqlite:
  - collection: shippers
    file: _db/northwind.db
    query: |
      SELECT ShipperID, CompanyName, Phone,
             '/shippers/' || ShipperID || '.html' AS permalink
      FROM Shippers
```

Each row is rendered to `_site/shippers/<ShipperID>.html`.

### Common permalink template (with placeholders)

Set `permalink:` once on the collection and let Jekyll's standard
[permalink placeholders](https://jekyllrb.com/docs/permalinks/) resolve
against columns from the query:

```yaml
collections:
  shipper_pages:
    output: true
    permalink: /:path/:name-:title:output_ext

sqlite:
  - collection: shipper_pages
    file: _db/northwind.db
    query: |
      SELECT 'companies'             AS path,
             'shipper-' || ShipperID AS name,
             CompanyName             AS title,
             'Phone: ' || Phone      AS content
      FROM Shippers
```

The `path`, `name`, and `title` columns map to Jekyll's `:path`, `:name`,
and `:title` placeholders. `:output_ext` resolves to `.html` for the
generated documents.

{: .note }
> **`name` and `path` columns control the synthetic filename**
>
> Jekyll's `:name` and `:path` placeholders are derived from each
> document's *file path*, not from front-matter. The plugin therefore
> uses the `name` SQL column as the synthetic filename and the `path` SQL
> column as a subdirectory under `_<collection>/`.
>
> When neither column is present, the plugin falls back to a 1-based row
> id — equivalent to writing `_<collection>/1.md`, `_<collection>/2.md`,
> etc. So a permalink template like `/:path/:name:output_ext` still works
> without those columns, just with auto-generated names.

{: .note }
> **`title` column also drives `:title` in URLs**
>
> Jekyll's `:title` permalink placeholder normally reads `data["slug"]`
> (not `data["title"]`). The plugin populates `slug` from your `title`
> column automatically, so a `title` column in your SQL flows into the
> `:title` placeholder as you'd expect.

## Writing to `site.posts`

`posts` is a built-in Jekyll collection — anything in `site.posts` is treated
as a blog post. To write rows there, declare it like any other collection
and produce a `date` column (Jekyll requires posts to have a date):

```yaml
sqlite:
  - collection: posts
    file: _db/northwind.db
    query: |
      SELECT 'Order ' || OrderID AS title,
             OrderDate         AS date,
             OrderID, CustomerID, ShipName
      FROM Orders ORDER BY OrderID
```

The rows are now ordinary posts. `site.posts` returns them in
reverse-chronological order, `post.title`, `post.date`, `post.url` all work,
and the document renders through the default `_layouts/post.html`.

{: .note }
> **Works with existing Jekyll plugins**
>
> Because `site.posts` is the standard posts collection, plugins that read it
> work without any extra wiring:
>
> - [`jekyll-paginate-v2`](https://github.com/sverrirs/jekyll-paginate-v2) —
>   paginated index pages over your generated posts.
> - [`jekyll-feed`](https://github.com/jekyll/jekyll-feed) — Atom feed
>   (`/feed.xml`) is generated from the same posts.
> - [`jekyll-sitemap`](https://github.com/jekyll/jekyll-sitemap) — generated
>   pages are included automatically.
> - [`jekyll-archives`](https://github.com/jekyll/jekyll-archives) — category
>   and tag archive pages, if your query produces those columns.
>
> The same applies to user-defined collections with `output: true`: any
> plugin that walks `site.collections` will see the documents you generated.

## When to use `collection:` vs `data:`

| Use `collection:` when… | Use `data:` when… |
| --- | --- |
| You want each row to become a page (`output: true`) | You only need the data inside another template |
| You want `jekyll-paginate`, `jekyll-feed`, etc. to pick it up | You're hand-rolling presentation in Liquid |
| You want documents to have URLs and a layout | You want a plain array/hash for `jsonify` or similar |
| You're replacing [datapage_gen]({% link usage/datapage.md %}) | You need [nested]({% link usage/nested.md %}) sub-queries on each row |

{: .note }
> The collection must be declared under `collections:` in `_config.yml`
> before the `sqlite:` block can write to it. If it isn't declared, the
> plugin logs an error and skips the entry.

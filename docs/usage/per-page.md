---
title: Per-page Queries
nav_order: 0
parent: Usage
---

The exact same syntax can be used on a per-page basis to generate data within
each page. This is helpful for keeping page-specific queries within the page
itself. Here's an example:

```yaml
---
FeaturedSupplierID: 2
sqlite:
  - data: suppliers
    file: "_db/northwind.db"
    query: "SELECT CompanyName, SupplierID FROM suppliers ORDER BY SupplierID"
  - data: suppliers.products
    # This is a prepared query, where SupplierID is coming from the previous query.
    file: "_db/northwind.db"
    query: "SELECT ProductName, CategoryID,UnitPrice FROM products WHERE SupplierID = :SupplierID"
  # :FeaturedSupplierID is picked up automatically from the page frontmatter.
  - data: FeaturedSupplier
    file: "_db/northwind.db"
    query: "SELECT * SupplierID = :FeaturedSupplierID"
---
{%raw%}{{page.suppliers|jsonify}}{%endraw%}
```

This will generate a `page.suppliers` array with all the suppliers, and a `page.FeaturedSupplier` object with the details of the featured supplier.

Each supplier will have a `products` array with all the products for that supplier.

{: .note }
> Per Page Query
> 
> On the Demo website, a per-page query 
> is used on the restock page to generate
> list of products that need to be restocked. You can see the
> [source](https://github.com/captn3m0/northwind/blob/main/restock.md?plain=1)
> and the [resulting page](https://northwind.captnemo.in/restock.html)
---
title: Nested Queries
parent: Usage
nav_order: 4
---
Starting from `0.2.0`, queries can be nested infinitely.

The following configuration is used in the [Demo]({% link demo.md %}):

```yaml
sqlite:
- data: regions
  file: *db
  query: |
    SELECT RegionID, RegionDescription FROM Regions
    ORDER BY RegionID

- data: regions.territories
  file: *db
  query: |
    SELECT TerritoryID, TerritoryDescription FROM Territories 
    WHERE RegionID = :RegionID
    ORDER BY TerritoryDescription

- data: regions.territories.EmployeeIDs
  file: *db
  query: |
    SELECT T.EmployeeID as EmployeeID, FirstName,LastName
    FROM EmployeeTerritories T,Employees
    WHERE T.TerritoryID = :TerritoryID
    AND T.EmployeeID = Employees.EmployeeID
```    

The first query generates `site.data.regions` as a list. The second query
sets territories inside each of the regions, and the third query
sets the list of employees inside each territory.

{: .note }
> Per Page Query
> 
> On the Demo website, you can see the result at 
> [the regions page](https://northwind.captnemo.in/regions.html)
> where each region is broken into territories, with the name 
> of the employee under each region.
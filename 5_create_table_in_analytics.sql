DROP TABLE IF EXISTS `projet_id.analytics_zone.reporte_ventas`;
CREATE TABLE `projet_id.analytics_zone.reporte_ventas` AS
select b.OrderDate,
       b.Status,
       b.CustomerID,
       coalesce(d.Title,'') || ' ' || coalesce(d.FirstName,'') || ' '|| coalesce(d.MiddleName,'') || ' ' ||coalesce(d.LastName,'') CustomerName,
       b.SalesPersonID,
       coalesce(h.Title,'') || ' ' || coalesce(h.FirstName,'') || ' '|| coalesce(h.MiddleName,'') || ' ' ||coalesce(h.LastName,'') SellerName,
       b.TerritoryID,
       i.Name TerritoryName,
       i.Group TerritoryGroup,
       a.ProductID,
       j.Name ProductName,
       k.Name ProductSubcategory,
       l.Name ProductCategory,
       m.Name ProductModel,
       a.OrderQty,
       a.LineTotal
from `projet_id.raw_zone2.SalesOrderDetail` a
left join `projet_id.raw_zone2.SalesOrderHeader` b on a.SalesOrderID=b.SalesOrderID
left join `projet_id.raw_zone2.Customer` c on b.CustomerID=c.CustomerID
left join `projet_id.raw_zone2.Person` d on c.PersonID=d.BusinessEntityID
left join `projet_id.raw_zone2.SalesPerson` e on b.SalesPersonID=e.BusinessEntityID
left join `projet_id.raw_zone2.Employee` f on e.BusinessEntityID=f.BusinessEntityID
left join `projet_id.raw_zone2.SalesTerritory` g on e.TerritoryID=g.TerritoryID
left join `projet_id.raw_zone2.Person` h on e.BusinessEntityID=h.BusinessEntityID
left join `projet_id.raw_zone2.SalesTerritory` i on b.TerritoryID=i.TerritoryID
left join `projet_id.raw_zone2.Product` j on a.ProductID=j.ProductID
left join `projet_id.raw_zone2.ProductSubcategory` k on j.ProductSubcategoryID=k.ProductSubcategoryID
left join `projet_id.raw_zone2.ProductCategory` l on k.ProductCategoryID=l.ProductCategoryID
left join `projet_id.raw_zone2.ProductModel` m on j.ProductModelID=m.ProductModelID
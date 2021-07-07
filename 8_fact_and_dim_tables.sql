
--https://github.com/salrashid123/bq-udf-xml
--https://stackoverflow.com/questions/50402276/big-query-user-defined-function-dramatically-slows-down-the-query
drop function if exists raw_zone2.xml_to_json;
CREATE FUNCTION raw_zone2.xml_to_json(a STRING)
  RETURNS STRING  
  LANGUAGE js AS
"""  
      return  frmXML(a);
"""    
OPTIONS (
  library=["gs://bk_sqlserver_ahg/xml_udf.js"]
);


DROP TABLE IF EXISTS `proyecto-bigdata-318002.staging_zone.DimPersona`;
CREATE TABLE `proyecto-bigdata-318002.staging_zone.DimPersona` AS
SELECT 
    p.BusinessEntityID PersonaID,
coalesce(p.Title,'') || ' ' || coalesce(p.FirstName,'') || ' '||
    coalesce(p.MiddleName,'') || ' ' ||coalesce(p.LastName,'') NombreCompleto,
    p.Title Abreviatura,
    p.FirstName PrimerNombre,
    p.MiddleName SegundoNombre,
    p.LastName ApellidoPaterno,
    p.Suffix Sufijo,
    pp.PhoneNumber Telefono,
    pnt.Name AS TipoTelefono ,
    ea.EmailAddress Correo,
    p.EmailPromotion CorreoMarketing,
    adt.Name AS TipoDireccion,
    a.AddressLine1 Direcccion1,
    a.AddressLine2 Direccion2,
    a.City Ciudad,
    sp.Name as Provincia,
    a.PostalCode CodigoPostal,
    cr.Name as Pais,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.TotalPurchaseYTD._text'),"\"","") AS DECIMAL) TotalComprasYTD,
CAST(REPLACE(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.DateFirstPurchase._text'),"\"",""),"Z","") AS DATE) PrimeraFechaCompra,
CAST(REPLACE(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.BirthDate._text'),"\"",""),"Z","") AS DATE) FechaNacimiento,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.MaritalStatus._text'),"\"","") AS STRING) EstadoCivil,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.YearlyIncome._text'),"\"","") AS STRING) IngresoAnual,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.Gender._text'),"\"","") AS STRING) Genero,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.TotalChildren._text'),"\"","") AS INTEGER) TotalHijos,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.NumberChildrenAtHome._text'),"\"","") AS INTEGER) NumeroNinosEnCasa,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.Education._text'),"\"","") AS STRING) Educacion,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.Occupation._text'),"\"","") AS STRING) Profesion,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.HomeOwnerFlag._text'),"\"","") AS INTEGER) DuenoCasa,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.NumberCarsOwned._text'),"\"","") AS INTEGER) NumeroCarros,
CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(p.Demographics),'$.IndividualSurvey.CommuteDistance._text'),"\"","") AS STRING) DistanciaTrabajo
FROM  `proyecto-bigdata-318002.raw_zone2.Person` p
LEFT JOIN (SELECT * FROM (
        SELECT *, ROW_NUMBER() over (PARTITION BY BusinessEntityID ORDER BY ModifiedDate DESC) RN
        FROM `proyecto-bigdata-318002.raw_zone2.BusinessEntityAddress`) A WHERE RN=1) bea ON bea.BusinessEntityID = p.BusinessEntityID
LEFT JOIN `proyecto-bigdata-318002.raw_zone2.Address` a ON a.AddressID = bea.AddressID
LEFT JOIN `proyecto-bigdata-318002.raw_zone2.StateProvince` sp ON sp.StateProvinceID = a.StateProvinceID
LEFT JOIN `proyecto-bigdata-318002.raw_zone2.CountryRegion` cr ON cr.CountryRegionCode = sp.CountryRegionCode
LEFT JOIN `proyecto-bigdata-318002.raw_zone2.AddressType` adt ON adt.AddressTypeID = bea.AddressTypeID
LEFT OUTER JOIN `proyecto-bigdata-318002.raw_zone2.EmailAddress` ea ON ea.BusinessEntityID = p.BusinessEntityID
LEFT OUTER JOIN `proyecto-bigdata-318002.raw_zone2.PersonPhone` pp ON pp.BusinessEntityID = p.BusinessEntityID
LEFT OUTER JOIN `proyecto-bigdata-318002.raw_zone2.PhoneNumberType` pnt ON pnt.PhoneNumberTypeID = pp.PhoneNumberTypeID;


select count(1),count(distinct PersonaID) from `proyecto-bigdata-318002.staging_zone.DimPersona`

DROP TABLE IF EXISTS `proyecto-bigdata-318002.staging_zone.DimCliente`;
CREATE TABLE `proyecto-bigdata-318002.staging_zone.DimCliente` AS
select a.CustomerID ClienteID, b.*
FROM `proyecto-bigdata-318002.raw_zone2.Customer` a
left join `proyecto-bigdata-318002.staging_zone.DimPersona` b on a.PersonID = b.PersonaID
WHERE a.PersonID IS not NULL;

select count(1),count(distinct CustomerID) from `proyecto-bigdata-318002.staging_zone.DimCliente`

DROP TABLE IF EXISTS `proyecto-bigdata-318002.staging_zone.DimVendedor`;
CREATE TABLE `proyecto-bigdata-318002.staging_zone.DimVendedor` AS
select a.BusinessEntityID VendedorID, b.*
FROM `proyecto-bigdata-318002.raw_zone2.SalesPerson` a
left join `proyecto-bigdata-318002.staging_zone.DimPersona` b on a.BusinessEntityID = b.PersonaID;

select count(1),count(distinct VendedorID) from `proyecto-bigdata-318002.staging_zone.DimVendedor`

DROP TABLE IF EXISTS `proyecto-bigdata-318002.staging_zone.DimDistribuidor`;
CREATE TABLE `proyecto-bigdata-318002.staging_zone.DimDistribuidor` AS
SELECT
    s.BusinessEntityID DistribuidorID,
    s.Name Distribuidor,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.AnnualSales._text'),"\"","") AS INTEGER) VentasAnuales,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.AnnualRevenue._text'),"\"","") AS INTEGER) IngresosAnuales,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.BankName._text'),"\"","") AS STRING) Banco,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.BusinessType._text'),"\"","") AS STRING) TipoNegocio,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.YearOpened._text'),"\"","") AS INTEGER) AnoApertura,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.Specialty._text'),"\"","") AS STRING) Especialidad,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.SquareFeet._text'),"\"","") AS INTEGER) MetrosCuadrados,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.Brands._text'),"\"","") AS STRING) Marcas,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.Internet._text'),"\"","") AS STRING) Internet,
    CAST(REPLACE(JSON_EXTRACT(raw_zone2.xml_to_json(Demographics),'$.StoreSurvey.NumberEmployees._text'),"\"","") AS INTEGER) NumeroEmpleados
FROM `proyecto-bigdata-318002.raw_zone2.Store` s
left join `proyecto-bigdata-318002.raw_zone2.Customer` a on a.StoreID=s.BusinessEntityID and a.PersonID is null;

select count(1),count(distinct DistribuidorID) from `proyecto-bigdata-318002.staging_zone.DimDistribuidor`

DROP TABLE IF EXISTS `proyecto-bigdata-318002.staging_zone.DimTerritorio`;
CREATE TABLE `proyecto-bigdata-318002.staging_zone.DimTerritorio` AS
SELECT TerritoryID TerritorioID,
       Name Territorio,
       CountryRegionCode CodigoPais,
       `Group` Grupo,
       SalesYTD VentasYTD,
       SalesLastYear VentasUltimoAno,
       CostYTD CostoYTD,
       CostLastYear CostoUltimoAno
FROM `proyecto-bigdata-318002.raw_zone2.SalesTerritory`


DROP TABLE IF EXISTS `proyecto-bigdata-318002.staging_zone.DimProducto`;
CREATE TABLE `proyecto-bigdata-318002.staging_zone.DimProducto` AS
select
j.ProductID ProductoID,
J.Name Producto,
j.ProductNumber CodigoProducto,
j.FinishedGoodsFlag FlagProductoTerminado,
j.Color,
j.StandardCost CostoEstandar,
j.ListPrice PrecioLista,
K.Name SubCategoria,
l.Name Categoria,
m.Name Modelo
from `proyecto-bigdata-318002.raw_zone2.Product` j
left join `proyecto-bigdata-318002.raw_zone2.ProductSubcategory` k on j.ProductSubcategoryID=k.ProductSubcategoryID
left join `proyecto-bigdata-318002.raw_zone2.ProductCategory` l on k.ProductCategoryID=l.ProductCategoryID
left join `proyecto-bigdata-318002.raw_zone2.ProductModel` m on j.ProductModelID=m.ProductModelID
where j.FinishedGoodsFlag = TRUE ;



DROP TABLE IF EXISTS `proyecto-bigdata-318002.staging_zone.FactVentas`;
CREATE TABLE `proyecto-bigdata-318002.staging_zone.FactVentas` AS
select  A.SalesOrderID VentaID,
        A.OrderDate FechaVenta,
        A.OnlineOrderFlag FlagVentaOnline,
        A.Status Estado,
        A.CustomerID ClienteID,
        C.StoreID DistribuidorID,
        A.SalesPersonID VendedorID,
        A.TerritoryID TerritorioID,
        count(1) Items,
        sum(B.LineTotal) MontoTotal,
        array_agg(STRUCT(
        B.ProductID as ProductoID,
        B.OrderQty as Cantidad,
        B.LineTotal as Monto)) AS Detalle
FROM `proyecto-bigdata-318002.raw_zone2.SalesOrderHeader` A
    LEFT JOIN `proyecto-bigdata-318002.raw_zone2.SalesOrderDetail` B ON A.SalesOrderID=B.SalesOrderID
    LEFT JOIN `proyecto-bigdata-318002.raw_zone2.Customer` C ON A.CustomerID=C.CustomerID
group by a.SalesOrderID,
        a.OrderDate,
        a.OnlineOrderFlag,
        a.Status,
        a.CustomerID,
        C.StoreID,
        a.SalesPersonID,
        a.TerritoryID;




DROP TABLE IF EXISTS `proyecto-bigdata-318002.analytics_zone.TablonVentas`;
CREATE TABLE `proyecto-bigdata-318002.analytics_zone.TablonVentas` AS
SELECT A.VentaID,A.FechaVenta,A.FlagVentaOnline,A.Estado,A.Items,A.MontoTotal,A.Detalle,
    STRUCT(B.ClienteID,B.PersonaID,B.NombreCompleto,B.Abreviatura,B.PrimerNombre,B.SegundoNombre,
    B.ApellidoPaterno,B.Sufijo,B.Telefono,B.TipoTelefono,B.Correo,B.CorreoMarketing,B.TipoDireccion,
    B.Direcccion1,B.Direccion2,B.Ciudad,B.Provincia,B.CodigoPostal,B.Pais,B.TotalComprasYTD,
    B.PrimeraFechaCompra,B.FechaNacimiento,B.EstadoCivil,B.IngresoAnual,B.Genero,B.TotalHijos,
    B.NumeroNinosEnCasa,B.Educacion,B.Profesion,B.DuenoCasa,B.NumeroCarros,B.DistanciaTrabajo) as Cliente,
    STRUCT(C.DistribuidorID,C.Distribuidor,C.VentasAnuales,C.IngresosAnuales,C.Banco,C.TipoNegocio,
    C.AnoApertura,C.Especialidad,C.MetrosCuadrados,C.Marcas,C.Internet,C.NumeroEmpleados) as Distribuidor,
    STRUCT(D.TerritorioID,D.Territorio,D.CodigoPais,D.Grupo,D.VentasYTD,D.VentasUltimoAno,D.CostoYTD,D.CostoUltimoAno) Territorio,
    STRUCT(E.VendedorID,E.PersonaID,E.NombreCompleto,E.Abreviatura,E.PrimerNombre,
    E.SegundoNombre,E.ApellidoPaterno,E.Sufijo,E.Telefono,E.TipoTelefono,E.Correo,
    E.CorreoMarketing,E.TipoDireccion,E.Direcccion1,E.Direccion2,E.Ciudad,
    E.Provincia,E.CodigoPostal,E.Pais,E.TotalComprasYTD,E.PrimeraFechaCompra,
    E.FechaNacimiento,E.EstadoCivil,E.IngresoAnual,E.Genero,E.TotalHijos,
    E.NumeroNinosEnCasa,E.Educacion,E.Profesion,E.DuenoCasa,E.NumeroCarros,E.DistanciaTrabajo) as Vendedor
FROM (
SELECT A.VentaID,A.FechaVenta,A.FlagVentaOnline,A.Estado,A.ClienteID,A.DistribuidorID,A.VendedorID,A.TerritorioID,A.Items,A.MontoTotal,
array_agg(STRUCT(
        STRUCT(E.ProductoID,E.Producto,E.CodigoProducto,E.FlagProductoTerminado,E.Color,E.CostoEstandar,E.PrecioLista,E.SubCategoria,E.Categoria,E.Modelo) AS Producto,
        D.Cantidad,
        D.Monto)) AS Detalle
FROM `proyecto-bigdata-318002.staging_zone.FactVentas`A, UNNEST(Detalle) as D
LEFT JOIN `proyecto-bigdata-318002.staging_zone.DimProducto` E ON D.ProductoID=E.ProductoID
GROUP BY A.VentaID,A.FechaVenta,A.FlagVentaOnline,A.Estado,A.ClienteID,A.DistribuidorID,A.VendedorID,A.TerritorioID,A.Items,A.MontoTotal) A 
LEFT JOIN `proyecto-bigdata-318002.staging_zone.DimCliente` B ON A.ClienteID=B.ClienteID
LEFT JOIN `proyecto-bigdata-318002.staging_zone.DimDistribuidor` C ON A.DistribuidorID=C.DistribuidorID
LEFT JOIN `proyecto-bigdata-318002.staging_zone.DimTerritorio` D ON A.TerritorioID=D.TerritorioID
LEFT JOIN `proyecto-bigdata-318002.staging_zone.DimVendedor` E ON A.VendedorID=E.VendedorID


--SELECT COUNT(1),SUM(Items) FROM `proyecto-bigdata-318002.staging_zone.FactVentas`
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.SalesOrderDetail gs://bk_sqlserver_ahg/tablas/SalesOrderDetail.csv schemas/SalesOrderDetail.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.SalesOrderHeader gs://bk_sqlserver_ahg/tablas/SalesOrderHeader.csv schemas/SalesOrderHeader.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.Customer gs://bk_sqlserver_ahg/tablas/Customer.csv schemas/Customer.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.Person gs://bk_sqlserver_ahg/tablas/Person.csv schemas/Person.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.SalesPerson gs://bk_sqlserver_ahg/tablas/SalesPerson.csv schemas/SalesPerson.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.Employee gs://bk_sqlserver_ahg/tablas/Employee.csv schemas/Employee.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.SalesTerritory gs://bk_sqlserver_ahg/tablas/SalesTerritory.csv schemas/SalesTerritory.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.Product gs://bk_sqlserver_ahg/tablas/Product.csv schemas/Product.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.ProductSubcategory gs://bk_sqlserver_ahg/tablas/ProductSubcategory.csv schemas/ProductSubcategory.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.ProductCategory gs://bk_sqlserver_ahg/tablas/ProductCategory.csv schemas/ProductCategory.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.ProductModel gs://bk_sqlserver_ahg/tablas/ProductModel.csv schemas/ProductModel.json
#new tables
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.BusinessEntityAddress gs://bk_sqlserver_ahg/tablas/BusinessEntityAddress.csv schemas/BusinessEntityAddress.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.Address gs://bk_sqlserver_ahg/tablas/Address.csv schemas/Address.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.StateProvince gs://bk_sqlserver_ahg/tablas/StateProvince.csv schemas/StateProvince.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.CountryRegion gs://bk_sqlserver_ahg/tablas/CountryRegion.csv schemas/CountryRegion.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.AddressType gs://bk_sqlserver_ahg/tablas/AddressType.csv schemas/AddressType.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.EmailAddress gs://bk_sqlserver_ahg/tablas/EmailAddress.csv schemas/EmailAddress.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.PersonPhone gs://bk_sqlserver_ahg/tablas/PersonPhone.csv schemas/PersonPhone.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.PhoneNumberType gs://bk_sqlserver_ahg/tablas/PhoneNumberType.csv schemas/PhoneNumberType.json
bq load --source_format=CSV --replace --skip_leading_rows=1 --allow_quoted_newlines raw_zone.Store gs://bk_sqlserver_ahg/tablas/Store.csv schemas/Store.json




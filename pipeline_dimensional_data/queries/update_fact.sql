USE ORDER_DDS;
GO

INSERT INTO dbo.FactOrders (
    OrderID_FK,
    ProductID_FK,
    CustomerID_FK,
    EmployeeID_FK,
    ShipperID_FK,
    OrderDate,
    RequiredDate,
    ShippedDate,
    Freight,
    Quantity,
    UnitPrice,
    Discount
)
SELECT 
    o.OrderID,
    dp.ProductID_SK_PK,
    dc.CustomerID_Table_SK,
    de.EmployeeID_SK_PK,
    ds.ShipperID_SK_PK,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    o.Freight,
    od.Quantity,
    od.UnitPrice,
    od.Discount
FROM dbo.Staging_Orders o
JOIN dbo.Staging_OrderDetails od
    ON o.OrderID = od.OrderID
JOIN dbo.DimCustomers_SCD2 dc
    ON o.CustomerID = dc.CustomerID_NK AND dc.IsCurrent = 1
JOIN dbo.DimEmployees_SCD1 de
    ON o.EmployeeID = de.EmployeeID_NK
JOIN dbo.DimShippers_SCD3 ds
    ON o.ShipVia = ds.ShipperID_NK
JOIN dbo.DimProducts_SCD4 dp
    ON od.ProductID = dp.ProductID_NK
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Orders'
   AND sor.TablePrimaryKeyColumn = 'OrderID';
GO


DECLARE @DatabaseName NVARCHAR(128) = 'ORDER_DDS';
DECLARE @SchemaName NVARCHAR(128) = 'dbo';
DECLARE @TableName NVARCHAR(128) = 'FactOrders';
DECLARE @start_date DATE = '2020-01-01';
DECLARE @end_date DATE = '2025-12-31';

USE [ORDER_DDS];
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
    so.OrderID,
    dp.ProductID_SK_PK,
    dc.CustomerID_Table_SK,
    de.EmployeeID_SK_PK,
    ds.ShipperID_SK_PK,
    so.OrderDate,
    so.RequiredDate,
    so.ShippedDate,
    so.Freight,
    sod.Quantity,
    sod.UnitPrice,
    sod.Discount
FROM dbo.Staging_Orders AS so
JOIN dbo.Staging_OrderDetails AS sod
    ON so.OrderID = sod.OrderID
JOIN dbo.DimCustomers_SCD2 AS dc
    ON dc.CustomerID_NK = so.CustomerID
    AND dc.IsCurrent = 1
JOIN dbo.DimEmployees_SCD1 AS de
    ON de.EmployeeID_NK = so.EmployeeID
JOIN dbo.DimShippers_SCD3 AS ds
    ON ds.ShipperID_NK = so.ShipVia
JOIN dbo.DimProducts_SCD4 AS dp
    ON dp.ProductID_NK = sod.ProductID
WHERE so.OrderDate BETWEEN @start_date AND @end_date;

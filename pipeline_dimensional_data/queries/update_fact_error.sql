DECLARE @DatabaseName NVARCHAR(128) = 'ORDER_DDS';
DECLARE @SchemaName NVARCHAR(128) = 'dbo';
DECLARE @TableName NVARCHAR(128) = 'fact_error';
DECLARE @start_date DATE = '2020-01-01';
DECLARE @end_date DATE = '2025-12-31';

USE [ORDER_DDS];
GO

INSERT INTO dbo.fact_error (
    OrderID,
    ProductID,
    CustomerID,
    EmployeeID,
    ShipperID,
    OrderDate,
    RequiredDate,
    ShippedDate,
    Freight,
    Quantity,
    UnitPrice,
    Discount,
    ErrorReason,
    SORKey,
    staging_raw_id
)
SELECT 
    so.OrderID,
    sod.ProductID,
    so.CustomerID,
    so.EmployeeID,
    so.ShipVia,
    so.OrderDate,
    so.RequiredDate,
    so.ShippedDate,
    so.Freight,
    sod.Quantity,
    sod.UnitPrice,
    sod.Discount,
    CASE 
        WHEN dc.CustomerID_Table_SK IS NULL THEN 'Missing Customer'
        WHEN dp.ProductID_SK_PK IS NULL THEN 'Missing Product'
        WHEN de.EmployeeID_SK_PK IS NULL THEN 'Missing Employee'
        WHEN ds.ShipperID_SK_PK IS NULL THEN 'Missing Shipper'
    END AS ErrorReason,
    sor.SORKey,
    so.staging_raw_id
FROM dbo.Staging_Orders so
JOIN dbo.Staging_OrderDetails sod ON so.OrderID = sod.OrderID
LEFT JOIN dbo.DimCustomers_SCD2 dc
    ON dc.CustomerID_NK = so.CustomerID AND dc.IsCurrent = 1
LEFT JOIN dbo.DimEmployees_SCD1 de
    ON de.EmployeeID_NK = so.EmployeeID
LEFT JOIN dbo.DimShippers_SCD3 ds
    ON ds.ShipperID_NK = so.ShipVia
LEFT JOIN dbo.DimProducts_SCD4 dp
    ON dp.ProductID_NK = sod.ProductID
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Orders'
   AND sor.TablePrimaryKeyColumn = 'OrderID'
WHERE so.OrderDate BETWEEN @start_date AND @end_date
  AND (
        dc.CustomerID_Table_SK IS NULL OR
        de.EmployeeID_SK_PK IS NULL OR
        ds.ShipperID_SK_PK IS NULL OR
        dp.ProductID_SK_PK IS NULL
  );
GO

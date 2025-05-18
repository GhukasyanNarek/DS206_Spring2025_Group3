USE ORDER_DDS;
GO

MERGE INTO dbo.Dim_SOR AS TARGET
USING (
    SELECT 'Staging_Categories' AS StagingTableName, 'CategoryID' AS TablePrimaryKeyColumn FROM Staging_Categories UNION ALL
    SELECT 'Staging_Customers', 'CustomerID' FROM Staging_Customers UNION ALL
    SELECT 'Staging_Employees', 'EmployeeID' FROM Staging_Employees UNION ALL
    SELECT 'Staging_OrderDetails', 'OrderID' FROM Staging_OrderDetails UNION ALL 
    SELECT 'Staging_Orders', 'OrderID' FROM Staging_Orders UNION ALL
    SELECT 'Staging_Products', 'ProductID' FROM Staging_Products UNION ALL
    SELECT 'Staging_Region', 'RegionID' FROM Staging_Region UNION ALL
    SELECT 'Staging_Shippers', 'ShipperID' FROM Staging_Shippers UNION ALL
    SELECT 'Staging_Suppliers', 'SupplierID' FROM Staging_Suppliers UNION ALL
    SELECT 'Staging_Territories', 'TerritoryID' FROM Staging_Territories
) AS SOURCE
ON TARGET.StagingTableName = SOURCE.StagingTableName AND TARGET.TablePrimaryKeyColumn = SOURCE.TablePrimaryKeyColumn
WHEN NOT MATCHED THEN
    INSERT (StagingTableName, TablePrimaryKeyColumn)
    VALUES (SOURCE.StagingTableName, SOURCE.TablePrimaryKeyColumn);
USE ORDER_DDS;
GO

INSERT INTO dbo.DimProducts_History (
    SORKey,
    ProductID_NK,
    ProductID_DURABLE_SK,
    ProductName,
    SupplierID,
    CategoryID,
    QuantityPerUnit,
    UnitPrice,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    Discontinued,
    ValidFrom,
    EndDate
)
SELECT 
    sor.SORKey,
    dp.ProductID_NK,
    dp.ProductID_DURABLE_SK,
    dp.ProductName,
    dp.SupplierID,
    dp.CategoryID,
    dp.QuantityPerUnit,
    dp.UnitPrice,
    dp.UnitsInStock,
    dp.UnitsOnOrder,
    dp.ReorderLevel,
    dp.Discontinued,
    dp.LastUpdated AS ValidFrom,
    GETDATE()     AS EndDate
FROM dbo.DimProducts_SCD4 dp
JOIN dbo.Staging_Products sp
    ON dp.ProductID_NK = sp.ProductID
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Products'
   AND sor.TablePrimaryKeyColumn = 'ProductID'
WHERE
    ISNULL(dp.ProductName, '')         <> ISNULL(sp.ProductName, '') OR
    ISNULL(dp.SupplierID, -1)          <> ISNULL(sp.SupplierID, -1) OR
    ISNULL(dp.CategoryID, -1)          <> ISNULL(sp.CategoryID, -1) OR
    ISNULL(dp.QuantityPerUnit, '')     <> ISNULL(sp.QuantityPerUnit, '') OR
    ISNULL(dp.UnitPrice, 0.0)          <> ISNULL(sp.UnitPrice, 0.0) OR
    ISNULL(dp.UnitsInStock, 0)         <> ISNULL(sp.UnitsInStock, 0) OR
    ISNULL(dp.UnitsOnOrder, 0)         <> ISNULL(sp.UnitsOnOrder, 0) OR
    ISNULL(dp.ReorderLevel, 0)         <> ISNULL(sp.ReorderLevel, 0) OR
    ISNULL(dp.Discontinued, 0)         <> ISNULL(sp.Discontinued, 0);
GO

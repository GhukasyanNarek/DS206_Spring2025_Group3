USE ORDER_DDS;

-- 1. Insert historical version of changed rows into DimProducts_History
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
    dp.SORKey,
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
    dp.LastUpdated,
    GETDATE()
FROM dbo.DimProducts_SCD4 dp
JOIN dbo.Staging_Products sp
    ON dp.ProductID_NK = sp.ProductID
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

-- 2. Update existing rows (if matched and changed)
MERGE INTO dbo.DimProducts_SCD4 AS TARGET
USING (
    SELECT 
        sp.ProductID,
        sp.ProductName,
        sp.SupplierID,
        sp.CategoryID,
        sp.QuantityPerUnit,
        sp.UnitPrice,
        sp.UnitsInStock,
        sp.UnitsOnOrder,
        sp.ReorderLevel,
        sp.Discontinued,
        sor.SORKey
    FROM dbo.Staging_Products sp
    JOIN dbo.Dim_SOR sor
        ON sor.StagingTableName = 'Staging_Products'
       AND sor.TablePrimaryKeyColumn = 'ProductID'
) AS SOURCE
ON TARGET.ProductID_NK = SOURCE.ProductID
WHEN MATCHED AND (
    ISNULL(TARGET.ProductName, '')     <> ISNULL(SOURCE.ProductName, '') OR
    ISNULL(TARGET.SupplierID, -1)      <> ISNULL(SOURCE.SupplierID, -1) OR
    ISNULL(TARGET.CategoryID, -1)      <> ISNULL(SOURCE.CategoryID, -1) OR
    ISNULL(TARGET.QuantityPerUnit, '') <> ISNULL(SOURCE.QuantityPerUnit, '') OR
    ISNULL(TARGET.UnitPrice, 0.0)      <> ISNULL(SOURCE.UnitPrice, 0.0) OR
    ISNULL(TARGET.UnitsInStock, 0)     <> ISNULL(SOURCE.UnitsInStock, 0) OR
    ISNULL(TARGET.UnitsOnOrder, 0)     <> ISNULL(SOURCE.UnitsOnOrder, 0) OR
    ISNULL(TARGET.ReorderLevel, 0)     <> ISNULL(SOURCE.ReorderLevel, 0) OR
    ISNULL(TARGET.Discontinued, 0)     <> ISNULL(SOURCE.Discontinued, 0)
)
THEN UPDATE SET
    TARGET.ProductID_DURABLE_SK = CAST(SOURCE.ProductID AS NVARCHAR(10)),
    TARGET.ProductName = SOURCE.ProductName,
    TARGET.SupplierID = SOURCE.SupplierID,
    TARGET.CategoryID = SOURCE.CategoryID,
    TARGET.QuantityPerUnit = SOURCE.QuantityPerUnit,
    TARGET.UnitPrice = SOURCE.UnitPrice,
    TARGET.UnitsInStock = SOURCE.UnitsInStock,
    TARGET.UnitsOnOrder = SOURCE.UnitsOnOrder,
    TARGET.ReorderLevel = SOURCE.ReorderLevel,
    TARGET.Discontinued = SOURCE.Discontinued,
    TARGET.LastUpdated = GETDATE();

-- 3. Insert new rows (not yet present)
INSERT INTO dbo.DimProducts_SCD4 (
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
    LastUpdated
)
SELECT 
    sor.SORKey,
    sp.ProductID,
    CAST(sp.ProductID AS NVARCHAR(10)),
    sp.ProductName,
    sp.SupplierID,
    sp.CategoryID,
    sp.QuantityPerUnit,
    sp.UnitPrice,
    sp.UnitsInStock,
    sp.UnitsOnOrder,
    sp.ReorderLevel,
    sp.Discontinued,
    GETDATE()
FROM dbo.Staging_Products sp
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Products'
   AND sor.TablePrimaryKeyColumn = 'ProductID'
LEFT JOIN dbo.DimProducts_SCD4 dp
    ON dp.ProductID_NK = sp.ProductID
WHERE dp.ProductID_NK IS NULL;
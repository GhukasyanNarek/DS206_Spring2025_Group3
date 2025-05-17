USE ORDER_DDS;


INSERT INTO dbo.DimProducts_History (
    SORKey,
    ProductID_SK_FK,            -- ✅ Correct foreign key
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
    dp.ProductID_SK_PK,        -- ✅ Get the surrogate key
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
    GETDATE() AS EndDate
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



MERGE INTO dbo.DimProducts_SCD4 AS TARGET
USING (
    SELECT 
        sp.staging_raw_id,
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
WHEN MATCHED THEN
    UPDATE SET
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
        TARGET.LastUpdated = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (
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
    VALUES (
        SOURCE.SORKey,
        SOURCE.ProductID,
        CAST(SOURCE.ProductID AS NVARCHAR(10)),
        SOURCE.ProductName,
        SOURCE.SupplierID,
        SOURCE.CategoryID,
        SOURCE.QuantityPerUnit,
        SOURCE.UnitPrice,
        SOURCE.UnitsInStock,
        SOURCE.UnitsOnOrder,
        SOURCE.ReorderLevel,
        SOURCE.Discontinued,
        GETDATE()
    );


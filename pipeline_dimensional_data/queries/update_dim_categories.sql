USE ORDER_DDS;
GO

MERGE INTO dbo.DimCategories_SCD1 AS TARGET
USING (
    SELECT 
        sc.staging_raw_id,
        sc.CategoryID,
        sc.CategoryName,
        sc.Description,
        sor.SORKey
    FROM dbo.Staging_Categories sc
    JOIN dbo.Dim_SOR sor
      ON sor.StagingTableName = 'Staging_Categories'
     AND sor.TablePrimaryKeyColumn = 'CategoryID'
) AS SOURCE
ON TARGET.CategoryID_NK = SOURCE.CategoryID
WHEN MATCHED THEN 
    UPDATE SET 
        TARGET.CategoryName = SOURCE.CategoryName,
        TARGET.Description  = SOURCE.Description,
        TARGET.IsDeleted    = 0,
        TARGET.ValidFrom    = GETDATE()
WHEN NOT MATCHED THEN 
    INSERT (
        CategoryID_NK,
        CategoryName,
        Description,
        IsDeleted,
        ValidFrom
    )
    VALUES (
        SOURCE.CategoryID,
        SOURCE.CategoryName,
        SOURCE.Description,
        0, 
        GETDATE()
    );
GO


UPDATE TARGET
SET TARGET.IsDeleted = 1
FROM dbo.DimCategories_SCD1 TARGET
LEFT JOIN dbo.Staging_Categories SC
    ON TARGET.CategoryID_NK = SC.CategoryID
WHERE SC.CategoryID IS NULL AND TARGET.IsDeleted = 0;
GO

USE ORDER_DDS;
GO

MERGE INTO dbo.DimRegion_SCD1 AS TARGET
USING (
    SELECT 
        sr.staging_raw_id,
        sr.RegionID,
        sr.RegionDescription,
        sr.RegionCategory,
        sr.RegionImportance,
        sor.SORKey
    FROM dbo.Staging_Region sr
    JOIN dbo.Dim_SOR sor
        ON sor.StagingTableName = 'Staging_Region'
       AND sor.TablePrimaryKeyColumn = 'RegionID'
) AS SOURCE
ON TARGET.RegionID_NK = SOURCE.RegionID
WHEN MATCHED THEN
    UPDATE SET
        TARGET.RegionDescription = SOURCE.RegionDescription,
        TARGET.RegionCategory = SOURCE.RegionCategory,
        TARGET.RegionImportance = SOURCE.RegionImportance
WHEN NOT MATCHED THEN
    INSERT (
        RegionID_NK,
        RegionDescription,
        RegionCategory,
        RegionImportance
    )
    VALUES (
        SOURCE.RegionID,
        SOURCE.RegionDescription,
        SOURCE.RegionCategory,
        SOURCE.RegionImportance
    );
GO

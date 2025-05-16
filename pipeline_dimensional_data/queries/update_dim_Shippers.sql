USE ORDER_DDS;



UPDATE TARGET
SET
    CompanyName_Prior = CompanyName_Current,
    Phone_Prior = Phone_Current,
    CompanyName_Current = SOURCE.CompanyName,
    Phone_Current = SOURCE.Phone,
    LastUpdated = GETDATE()
FROM dbo.DimShippers_SCD3 TARGET
JOIN (
    SELECT 
        ss.staging_raw_id,
        ss.ShipperID,
        ss.CompanyName,
        ss.Phone,
        sor.SORKey
    FROM dbo.Staging_Shippers ss
    JOIN dbo.Dim_SOR sor
        ON sor.StagingTableName = 'Staging_Shippers'
       AND sor.TablePrimaryKeyColumn = 'ShipperID'
) AS SOURCE
ON TARGET.ShipperID_NK = SOURCE.ShipperID
WHERE
    ISNULL(TARGET.CompanyName_Current, '') <> ISNULL(SOURCE.CompanyName, '') OR
    ISNULL(TARGET.Phone_Current, '')       <> ISNULL(SOURCE.Phone, '');



INSERT INTO dbo.DimShippers_SCD3 (
    ShipperID_NK,
    CompanyName_Current,
    Phone_Current,
    CompanyName_Prior,
    Phone_Prior,
    LastUpdated
)
SELECT 
    ss.ShipperID,
    ss.CompanyName,
    ss.Phone,
    NULL, 
    NULL,
    GETDATE()
FROM dbo.Staging_Shippers ss
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Shippers'
   AND sor.TablePrimaryKeyColumn = 'ShipperID'
LEFT JOIN dbo.DimShippers_SCD3 ds
    ON ds.ShipperID_NK = ss.ShipperID
WHERE ds.ShipperID_NK IS NULL;


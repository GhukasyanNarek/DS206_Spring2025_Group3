USE ORDER_DDS;


MERGE INTO dbo.DimSuppliers_SCD4 AS TARGET
USING (
    SELECT 
        ss.staging_raw_id,
        ss.SupplierID,
        ss.CompanyName,
        ss.ContactName,
        ss.ContactTitle,
        ss.Address,
        ss.City,
        ss.Region,
        ss.PostalCode,
        ss.Country,
        ss.Phone,
        ss.Fax,
        ss.HomePage,
        sor.SORKey
    FROM dbo.Staging_Suppliers ss
    JOIN dbo.Dim_SOR sor
        ON sor.StagingTableName = 'Staging_Suppliers'
       AND sor.TablePrimaryKeyColumn = 'SupplierID'
) AS SOURCE
ON TARGET.SupplierID_NK = SOURCE.SupplierID
WHEN MATCHED THEN
    UPDATE SET
        TARGET.CompanyName   = SOURCE.CompanyName,
        TARGET.ContactName   = SOURCE.ContactName,
        TARGET.ContactTitle  = SOURCE.ContactTitle,
        TARGET.Address       = SOURCE.Address,
        TARGET.City          = SOURCE.City,
        TARGET.Region        = SOURCE.Region,
        TARGET.PostalCode    = SOURCE.PostalCode,
        TARGET.Country       = SOURCE.Country,
        TARGET.Phone         = SOURCE.Phone,
        TARGET.Fax           = SOURCE.Fax,
        TARGET.HomePage      = SOURCE.HomePage,
        TARGET.LastUpdated   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (
        SORKey,
        SupplierID_NK,
        CompanyName,
        ContactName,
        ContactTitle,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        Phone,
        Fax,
        HomePage,
        LastUpdated
    )
    VALUES (
        SOURCE.SORKey,
        SOURCE.SupplierID,
        SOURCE.CompanyName,
        SOURCE.ContactName,
        SOURCE.ContactTitle,
        SOURCE.Address,
        SOURCE.City,
        SOURCE.Region,
        SOURCE.PostalCode,
        SOURCE.Country,
        SOURCE.Phone,
        SOURCE.Fax,
        SOURCE.HomePage,
        GETDATE()
    );


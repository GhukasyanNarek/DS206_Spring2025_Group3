USE ORDER_DDS;


MERGE INTO dbo.DimSuppliers_History AS TARGET
USING (
    SELECT 
        ss.staging_raw_id,
        sor.SORKey,
        ss.SupplierID,
        ss.CompanyName,
        ss.ContactName,
        ss.ContactTitle,
        ss.[Address],
        ss.City,
        ss.Region,
        ss.PostalCode,
        ss.Country,
        ss.Phone,
        ss.Fax,
        ss.HomePage,
        GETDATE() AS ValidFrom
    FROM dbo.Staging_Suppliers AS ss
    JOIN dbo.Dim_SOR AS sor 
        ON sor.StagingTableName = 'Staging_Suppliers'
        AND sor.TablePrimaryKeyColumn = 'SupplierID'
) AS SOURCE
ON TARGET.SupplierID = SOURCE.SupplierID
WHEN NOT MATCHED THEN
INSERT (
    staging_raw_id,
    SORKey,
    SupplierID,
    CompanyName,
    ContactName,
    ContactTitle,
    [Address],
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    HomePage,
    ValidFrom
)
VALUES (
    SOURCE.staging_raw_id,
    SOURCE.SORKey,
    SOURCE.SupplierID,
    SOURCE.CompanyName,
    SOURCE.ContactName,
    SOURCE.ContactTitle,
    SOURCE.[Address],
    SOURCE.City,
    SOURCE.Region,
    SOURCE.PostalCode,
    SOURCE.Country,
    SOURCE.Phone,
    SOURCE.Fax,
    SOURCE.HomePage,
    SOURCE.ValidFrom
);

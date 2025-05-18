USE ORDER_DDS;

INSERT INTO dbo.DimSuppliers_History (
    SORKey,
    SupplierID_NK,
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
    ValidFrom,
    EndDate
)
SELECT 
    sor.SORKey,
    ds.SupplierID_NK,
    ds.CompanyName,
    ds.ContactName,
    ds.ContactTitle,
    ds.[Address],
    ds.City,
    ds.Region,
    ds.PostalCode,
    ds.Country,
    ds.Phone,
    ds.Fax,
    ds.HomePage,
    ds.LastUpdated AS ValidFrom,
    GETDATE()     AS EndDate
FROM dbo.DimSuppliers_SCD4 ds
JOIN dbo.Staging_Suppliers ss
    ON ds.SupplierID_NK = ss.SupplierID
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Suppliers'
   AND sor.TablePrimaryKeyColumn = 'SupplierID'
WHERE
    ISNULL(ds.CompanyName, '')     <> ISNULL(ss.CompanyName, '') OR
    ISNULL(ds.ContactName, '')     <> ISNULL(ss.ContactName, '') OR
    ISNULL(ds.ContactTitle, '')    <> ISNULL(ss.ContactTitle, '') OR
    ISNULL(ds.[Address], '')       <> ISNULL(ss.[Address], '') OR
    ISNULL(ds.City, '')            <> ISNULL(ss.City, '') OR
    ISNULL(ds.Region, '')          <> ISNULL(ss.Region, '') OR
    ISNULL(ds.PostalCode, '')      <> ISNULL(ss.PostalCode, '') OR
    ISNULL(ds.Country, '')         <> ISNULL(ss.Country, '') OR
    ISNULL(ds.Phone, '')           <> ISNULL(ss.Phone, '') OR
    ISNULL(ds.Fax, '')             <> ISNULL(ss.Fax, '') OR
    ISNULL(ds.HomePage, '')        <> ISNULL(ss.HomePage, '');
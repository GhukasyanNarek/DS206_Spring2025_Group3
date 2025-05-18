USE ORDER_DDS;

UPDATE TARGET
SET 
    TARGET.ValidTo = GETDATE(),
    TARGET.IsCurrent = 0
FROM dbo.DimCustomers_SCD2 TARGET
JOIN (
    SELECT sc.*, sor.SORKey
    FROM dbo.Staging_Customers sc
    JOIN dbo.Dim_SOR sor
      ON sor.StagingTableName = 'Staging_Customers'
     AND sor.TablePrimaryKeyColumn = 'CustomerID'
) AS SOURCE
ON SOURCE.CustomerID = TARGET.CustomerID_NK
WHERE TARGET.IsCurrent = 1 AND (
    ISNULL(TARGET.CompanyName, '')    <> ISNULL(SOURCE.CompanyName, '') OR
    ISNULL(TARGET.ContactName, '')    <> ISNULL(SOURCE.ContactName, '') OR
    ISNULL(TARGET.ContactTitle, '')   <> ISNULL(SOURCE.ContactTitle, '') OR
    ISNULL(TARGET.Address, '')        <> ISNULL(SOURCE.Address, '') OR
    ISNULL(TARGET.City, '')           <> ISNULL(SOURCE.City, '') OR
    ISNULL(TARGET.Region, '')         <> ISNULL(SOURCE.Region, '') OR
    ISNULL(TARGET.PostalCode, '')     <> ISNULL(SOURCE.PostalCode, '') OR
    ISNULL(TARGET.Country, '')        <> ISNULL(SOURCE.Country, '') OR
    ISNULL(TARGET.Phone, '')          <> ISNULL(SOURCE.Phone, '') OR
    ISNULL(TARGET.Fax, '')            <> ISNULL(SOURCE.Fax, '')
);

INSERT INTO dbo.DimCustomers_SCD2 (
    SORKey,
    CustomerID_DURABLE_SK,
    CustomerID_NK,
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
    ValidFrom,
    ValidTo,
    IsCurrent
)
SELECT 
    sor.SORKey,
    sc.CustomerID,  
    sc.CustomerID,
    sc.CompanyName,
    sc.ContactName,
    sc.ContactTitle,
    sc.Address,
    sc.City,
    sc.Region,
    sc.PostalCode,
    sc.Country,
    sc.Phone,
    sc.Fax,
    GETDATE() AS ValidFrom,
    NULL AS ValidTo,
    1 AS IsCurrent
FROM dbo.Staging_Customers sc
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Customers'
   AND sor.TablePrimaryKeyColumn = 'CustomerID'
LEFT JOIN (
    SELECT *
    FROM dbo.DimCustomers_SCD2
    WHERE IsCurrent = 1
) tgt
    ON tgt.CustomerID_NK = sc.CustomerID
WHERE tgt.CustomerID_NK IS NULL
   OR (
        ISNULL(tgt.CompanyName, '')    <> ISNULL(sc.CompanyName, '') OR
        ISNULL(tgt.ContactName, '')    <> ISNULL(sc.ContactName, '') OR
        ISNULL(tgt.ContactTitle, '')   <> ISNULL(sc.ContactTitle, '') OR
        ISNULL(tgt.Address, '')        <> ISNULL(sc.Address, '') OR
        ISNULL(tgt.City, '')           <> ISNULL(sc.City, '') OR
        ISNULL(tgt.Region, '')         <> ISNULL(sc.Region, '') OR
        ISNULL(tgt.PostalCode, '')     <> ISNULL(sc.PostalCode, '') OR
        ISNULL(tgt.Country, '')        <> ISNULL(sc.Country, '') OR
        ISNULL(tgt.Phone, '')          <> ISNULL(sc.Phone, '') OR
        ISNULL(tgt.Fax, '')            <> ISNULL(sc.Fax, '')
   );
USE ORDER_DDS;
GO

MERGE INTO dbo.DimEmployees_SCD1 AS TARGET
USING (
    SELECT 
        se.staging_raw_id,
        se.EmployeeID,
        se.LastName,
        se.FirstName,
        se.Title,
        se.TitleOfCourtesy,
        se.BirthDate,
        se.HireDate,
        se.Address,
        se.City,
        se.Region,
        se.PostalCode,
        se.Country,
        se.HomePhone,
        se.Extension,
        se.Photo,
        se.Notes,
        se.ReportsTo,
        se.PhotoPath,
        sor.SORKey
    FROM dbo.Staging_Employees se
    JOIN dbo.Dim_SOR sor
      ON sor.StagingTableName = 'Staging_Employees'
     AND sor.TablePrimaryKeyColumn = 'EmployeeID'
) AS SOURCE
ON TARGET.EmployeeID_NK = SOURCE.EmployeeID
WHEN MATCHED THEN
    UPDATE SET
        TARGET.LastName = SOURCE.LastName,
        TARGET.FirstName = SOURCE.FirstName,
        TARGET.Title = SOURCE.Title,
        TARGET.TitleOfCourtesy = SOURCE.TitleOfCourtesy,
        TARGET.BirthDate = SOURCE.BirthDate,
        TARGET.HireDate = SOURCE.HireDate,
        TARGET.Address = SOURCE.Address,
        TARGET.City = SOURCE.City,
        TARGET.Region = SOURCE.Region,
        TARGET.PostalCode = SOURCE.PostalCode,
        TARGET.Country = SOURCE.Country,
        TARGET.HomePhone = SOURCE.HomePhone,
        TARGET.Extension = SOURCE.Extension,
        TARGET.Photo = SOURCE.Photo,
        TARGET.Notes = SOURCE.Notes,
        TARGET.ReportsTo = SOURCE.ReportsTo,
        TARGET.PhotoPath = SOURCE.PhotoPath,
        TARGET.IsDeleted = 0,
        TARGET.ValidFrom = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (
        EmployeeID_NK,
        LastName,
        FirstName,
        Title,
        TitleOfCourtesy,
        BirthDate,
        HireDate,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        HomePhone,
        Extension,
        Photo,
        Notes,
        ReportsTo,
        PhotoPath,
        IsDeleted,
        ValidFrom
    )
    VALUES (
        SOURCE.EmployeeID,
        SOURCE.LastName,
        SOURCE.FirstName,
        SOURCE.Title,
        SOURCE.TitleOfCourtesy,
        SOURCE.BirthDate,
        SOURCE.HireDate,
        SOURCE.Address,
        SOURCE.City,
        SOURCE.Region,
        SOURCE.PostalCode,
        SOURCE.Country,
        SOURCE.HomePhone,
        SOURCE.Extension,
        SOURCE.Photo,
        SOURCE.Notes,
        SOURCE.ReportsTo,
        SOURCE.PhotoPath,
        0,
        GETDATE()
    );
GO

UPDATE TARGET
SET IsDeleted = 1
FROM dbo.DimEmployees_SCD1 TARGET
LEFT JOIN dbo.Staging_Employees se
    ON TARGET.EmployeeID_NK = se.EmployeeID
WHERE se.EmployeeID IS NULL
  AND TARGET.IsDeleted = 0;
GO

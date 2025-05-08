USE ORDER_DDS;
GO


-- Dim_SOR Table
CREATE TABLE dbo.Dim_SOR (
    SORKey INT IDENTITY(1,1) PRIMARY KEY,
    StagingTableName NVARCHAR(255) NOT NULL,
    TablePrimaryKeyColumn NVARCHAR(255) NOT NULL
);

CREATE TABLE dbo.DimCategories_SCD1 (
    CategoryID_SK_PK INT IDENTITY(1,1) NOT NULL,
    CategoryID_NK INT NOT NULL,
    CategoryName NVARCHAR(255),
    Description NVARCHAR(MAX),
    IsDeleted BIT DEFAULT 0,                    
    ValidFrom DATE NULL,        
    CONSTRAINT PK_Categories_SCD1 PRIMARY KEY (CategoryID_SK_PK)
);


CREATE TABLE dbo.DimCustomers_SCD2 (
    CustomerID_Table_SK INT IDENTITY(1,1) NOT NULL,
    SORKey INT FOREIGN KEY REFERENCES dbo.Dim_SOR(SORKey),
    CustomerID_DURABLE_SK NVARCHAR(5) UNIQUE,
    CustomerID_NK NVARCHAR(5),
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    [Address] NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(255),
    Phone NVARCHAR(255),
    Fax NVARCHAR(255),
    ValidFrom DATE NULL,
    ValidTo DATE NULL,
    IsCurrent BIT NULL,
    CONSTRAINT PK_Customers_SCD2 PRIMARY KEY (CustomerID_Table_SK)
);

CREATE TABLE dbo.DimEmployees_SCD1 (
    EmployeeID_SK_PK INT IDENTITY(1,1) NOT NULL,
    EmployeeID_NK INT NOT NULL,
    LastName NVARCHAR(255),
    FirstName NVARCHAR(255),
    Title NVARCHAR(255),
    TitleOfCourtesy NVARCHAR(255),
    BirthDate DATETIME,
    HireDate DATETIME,
    [Address] NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(255),
    HomePhone NVARCHAR(255),
    Extension NVARCHAR(10),
    Photo VARBINARY(MAX),
    Notes NVARCHAR(MAX),
    ReportsTo INT,
    PhotoPath NVARCHAR(255),
    IsDeleted BIT DEFAULT 0,                    
    ValidFrom DATE NULL,        
    CONSTRAINT PK_Employees_SCD1 PRIMARY KEY (EmployeeID_SK_PK)
);

CREATE TABLE dbo.DimProducts_SCD4 (
    ProductID_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    SORKey INT FOREIGN KEY REFERENCES dbo.Dim_SOR(SORKey),
    ProductID_NK INT NOT NULL,
    ProductID_DURABLE_SK NVARCHAR(10) UNIQUE,
    ProductName NVARCHAR(255),
    SupplierID INT FOREIGN KEY REFERENCES dbo.DimSuppliers_SCD4(SupplierID_SK_PK),
    CategoryID INT FOREIGN KEY REFERENCES dbo.DimCategories_SCD1(CategoryID_SK_PK),
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(10,2),
    UnitsInStock SMALLINT,
    UnitsOnOrder SMALLINT,
    ReorderLevel SMALLINT,
    Discontinued BIT,
    LastUpdated DATE NULL
);


CREATE TABLE dbo.DimProducts_History (
    ProductID_History_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    SORKey INT FOREIGN KEY REFERENCES dbo.Dim_SOR(SORKey),
    ProductID_NK INT NOT NULL FOREIGN KEY REFERENCES dbo.DimProducts_SCD4(ProductID_NK),
    ProductID_DURABLE_SK NVARCHAR(10) UNIQUE,
    ProductName NVARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(10,2),
    UnitsInStock SMALLINT,
    UnitsOnOrder SMALLINT,
    ReorderLevel SMALLINT,
    Discontinued BIT,
    ValidFrom DATE NULL,
    EndDate DATE
);


CREATE TABLE dbo.DimRegion_SCD1 (
    RegionID_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    RegionID_NK INT UNIQUE,
    RegionDescription NVARCHAR(255),
    RegionCategory NVARCHAR(255),
    RegionImportance NVARCHAR(255)
)
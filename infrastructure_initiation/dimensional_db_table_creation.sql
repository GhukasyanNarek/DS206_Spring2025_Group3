USE ORDER_DDS;



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
    Notes NVARCHAR(MAX),
    ReportsTo INT,
    PhotoPath NVARCHAR(255),
    IsDeleted BIT DEFAULT 0,                    
    ValidFrom DATE NULL,        
    CONSTRAINT PK_Employees_SCD1 PRIMARY KEY (EmployeeID_SK_PK)
);

-- DimSuppliers
CREATE TABLE dbo.DimSuppliers_SCD4 (
    SupplierID_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    SORKey INT FOREIGN KEY REFERENCES dbo.Dim_SOR(SORKey),
    SupplierID_NK INT NOT NULL UNIQUE,
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    [Address] NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(255),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    HomePage NVARCHAR(MAX),
    LastUpdated DATE NULL
);


CREATE TABLE dbo.DimProducts_SCD4 (
    ProductID_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    SORKey INT FOREIGN KEY REFERENCES dbo.Dim_SOR(SORKey),
    ProductID_NK INT NOT NULL UNIQUE,
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

-- DimShippers 
CREATE TABLE dbo.DimShippers_SCD3 (
    ShipperID_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID_NK INT NOT NULL UNIQUE,
    CompanyName_Current NVARCHAR(255),
    Phone_Current NVARCHAR(50),
    CompanyName_Prior NVARCHAR(255),
    Phone_Prior NVARCHAR(50),
    LastUpdated DATE NULL
);





-- DimSuppliers_History Table (SCD4 History)
CREATE TABLE dbo.DimSuppliers_History (
    SupplierID_History_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    SORKey INT FOREIGN KEY REFERENCES dbo.Dim_SOR(SORKey),
    SupplierID_NK INT,
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    [Address] NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(255),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    HomePage NVARCHAR(MAX),
    ValidFrom DATE,
    EndDate DATE
);



-- DimTerritories
CREATE TABLE dbo.DimTerritories_SCD3 (
    TerritoryID_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID_NK NVARCHAR(20) NOT NULL UNIQUE,
    TerritoryDescription_Current NVARCHAR(255),
    RegionID_Current INT,
    TerritoryDescription_Prior NVARCHAR(255),
    RegionID_Prior INT,
    LastUpdated DATE NULL
);


-- FactOrders 
CREATE TABLE dbo.FactOrders (
    OrderID_FK INT,
    ProductID_FK INT,
    CustomerID_FK INT,
    EmployeeID_FK INT,
    ShipperID_FK INT,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    TerritoryID_FK INT,
    Freight DECIMAL(10,2),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    Discount FLOAT,
    CONSTRAINT PK_FactOrders PRIMARY KEY (OrderID_FK, ProductID_FK),
    FOREIGN KEY (CustomerID_FK) REFERENCES dbo.DimCustomers_SCD2(CustomerID_Table_SK),
    FOREIGN KEY (ProductID_FK) REFERENCES dbo.DimProducts_SCD4(ProductID_SK_PK),
    FOREIGN KEY (EmployeeID_FK) REFERENCES dbo.DimEmployees_SCD1(EmployeeID_SK_PK),
    FOREIGN KEY (ShipperID_FK) REFERENCES dbo.DimShippers_SCD3(ShipperID_SK_PK),
    FOREIGN KEY (TerritoryID_FK) REFERENCES dbo.DimTerritories_SCD3(TerritoryID_SK_PK)
);

-- FactOrders Error
CREATE TABLE dbo.FactOrders_Error (
    FactOrderErrorID_PK INT IDENTITY(1,1) PRIMARY KEY,
    OrderID_FK INT NOT NULL,
    MissingKeyType NVARCHAR(50) NOT NULL,
    StagingRawID INT NOT NULL,
    OrderDate DATETIME,
    ShipDate DATETIME,
    Quantity SMALLINT,
    TotalAmount DECIMAL(18,2)
);

-- Seed Dim_SOR
INSERT INTO dbo.Dim_SOR (StagingTableName, TablePrimaryKeyColumn)
VALUES 
    ('Staging_Categories', 'CategoryID'),
    ('Staging_Customers', 'CustomerID'),
    ('Staging_Employees', 'EmployeeID'),
    ('Staging_Products', 'ProductID'),
    ('Staging_Suppliers', 'SupplierID'),
    ('Staging_Region', 'RegionID'),
    ('Staging_Shippers', 'ShipperID'),
    ('Staging_Territories', 'TerritoryID');
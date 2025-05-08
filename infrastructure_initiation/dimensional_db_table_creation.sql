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
GO

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
GO

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
GO

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
    Freight DECIMAL(10,2),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    Discount FLOAT,
    CONSTRAINT PK_FactOrders PRIMARY KEY (OrderID_FK, ProductID_FK),
    FOREIGN KEY (CustomerID_FK) REFERENCES dbo.DimCustomers_SCD2(CustomerID_Table_SK),
    FOREIGN KEY (ProductID_FK) REFERENCES dbo.DimProducts_SCD4(ProductID_SK_PK),
    FOREIGN KEY (EmployeeID_FK) REFERENCES dbo.DimEmployees_SCD1(EmployeeID_SK_PK),
    FOREIGN KEY (ShipperID_FK) REFERENCES dbo.DimShippers_SCD3(ShipperID_SK_PK)
);
GO
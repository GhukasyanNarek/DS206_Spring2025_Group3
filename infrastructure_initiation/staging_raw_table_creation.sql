USE ORDER_DDS;

IF DB_ID('ORDER_DDS') IS NULL
BEGIN
    CREATE DATABASE ORDER_DDS;
END

USE ORDER_DDS;

IF OBJECT_ID('dbo.Staging_Categories','U') IS NOT NULL DROP TABLE dbo.Staging_Categories;
IF OBJECT_ID('dbo.Staging_Customers','U')  IS NOT NULL DROP TABLE dbo.Staging_Customers;
IF OBJECT_ID('dbo.Staging_Employees','U')  IS NOT NULL DROP TABLE dbo.Staging_Employees;
IF OBJECT_ID('dbo.Staging_OrderDetails','U') IS NOT NULL DROP TABLE dbo.Staging_OrderDetails;
IF OBJECT_ID('dbo.Staging_Orders','U')     IS NOT NULL DROP TABLE dbo.Staging_Orders;
IF OBJECT_ID('dbo.Staging_Products','U')   IS NOT NULL DROP TABLE dbo.Staging_Products;
IF OBJECT_ID('dbo.Staging_Region','U')    IS NOT NULL DROP TABLE dbo.Staging_Region;
IF OBJECT_ID('dbo.Staging_Shippers','U')   IS NOT NULL DROP TABLE dbo.Staging_Shippers;
IF OBJECT_ID('dbo.Staging_Suppliers','U')  IS NOT NULL DROP TABLE dbo.Staging_Suppliers;
IF OBJECT_ID('dbo.Staging_Territories','U') IS NOT NULL DROP TABLE dbo.Staging_Territories;


-- Categories Table
IF OBJECT_ID('dbo.Staging_Categories', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Categories;
CREATE TABLE dbo.Staging_Categories (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT,
    CategoryName NVARCHAR(255),
    Description NVARCHAR(MAX)
);

-- Customers Table
IF OBJECT_ID('dbo.Staging_Customers', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Customers;
CREATE TABLE dbo.Staging_Customers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(5),
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    [Address] NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(255),
    Phone NVARCHAR(255),
    Fax NVARCHAR(255)
);

-- Employees Table
IF OBJECT_ID('dbo.Staging_Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Employees;
CREATE TABLE dbo.Staging_Employees (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
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
    PhotoPath NVARCHAR(255)
);

-- Order Details Table
IF OBJECT_ID('dbo.Staging_OrderDetails', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_OrderDetails;
CREATE TABLE dbo.Staging_OrderDetails (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10,2),
    Quantity SMALLINT,
    Discount FLOAT
);


IF OBJECT_ID('dbo.Staging_Orders', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Orders;

CREATE TABLE dbo.Staging_Orders (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    CustomerID NVARCHAR(5),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight DECIMAL(10,2),
    ShipName NVARCHAR(255),
    ShipAddress NVARCHAR(255),
    ShipCity NVARCHAR(255),
    ShipRegion NVARCHAR(255),
    ShipPostalCode NVARCHAR(20),
    ShipCountry NVARCHAR(255),
    TerritoryID INT
);


-- Products Table
IF OBJECT_ID('dbo.Staging_Products', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Products;
CREATE TABLE dbo.Staging_Products (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ProductName NVARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(10,2),
    UnitsInStock SMALLINT,
    UnitsOnOrder SMALLINT,
    ReorderLevel SMALLINT,
    Discontinued BIT
);

-- Region Table
IF OBJECT_ID('dbo.Staging_Region', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Region;
CREATE TABLE dbo.Staging_Region (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT,
    RegionDescription NVARCHAR(255),
    RegionCategory NVARCHAR(255),
    RegionImportance NVARCHAR(255)
);

-- Shippers Table
IF OBJECT_ID('dbo.Staging_Shippers', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Shippers;
CREATE TABLE dbo.Staging_Shippers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT,
    CompanyName NVARCHAR(255),
    Phone NVARCHAR(255)
);

-- Suppliers Table
IF OBJECT_ID('dbo.Staging_Suppliers', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Suppliers;
CREATE TABLE dbo.Staging_Suppliers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT,
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
    HomePage NVARCHAR(MAX)
);

-- Territories Table
IF OBJECT_ID('dbo.Staging_Territories', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_Territories;
CREATE TABLE dbo.Staging_Territories (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID NVARCHAR(20),
    TerritoryDescription NVARCHAR(255),
    TerritoryCode NVARCHAR(5),  --na vsyaki 5)
    RegionID INT
);

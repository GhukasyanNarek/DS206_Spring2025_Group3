-- Categories Table
CREATE TABLE dbo.Staging_Categories (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT UNIQUE,
    CategoryName NVARCHAR(255),
    Description NVARCHAR(MAX)
);

-- Customers Table
CREATE TABLE dbo.Staging_Customers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(5) UNIQUE,
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

-- Shippers Table
CREATE TABLE dbo.Staging_Shippers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT UNIQUE,
    CompanyName NVARCHAR(255),
    Phone NVARCHAR(255)
);

-- Suppliers Table
CREATE TABLE dbo.Staging_Suppliers (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT UNIQUE,
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
CREATE TABLE dbo.Staging_Territories (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID NVARCHAR(20) UNIQUE,
    TerritoryDescription NVARCHAR(255),
    TerritoryCode NVARCHAR(5),  --na vsyaki 5)
    RegionID INT
);

-- Employees Table
CREATE TABLE dbo.Staging_Employees (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT UNIQUE,
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
    CONSTRAINT FK_Employees_ReportsTo FOREIGN KEY (ReportsTo) REFERENCES dbo.Staging_Employees(EmployeeID)
);

-- Staging Orders Table
CREATE TABLE dbo.Staging_Orders (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT UNIQUE,
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
    TerritoryID NVARCHAR(20),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Staging_Customers(CustomerID),
    CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeID) REFERENCES dbo.Staging_Employees(EmployeeID),
    CONSTRAINT FK_Orders_ShipVia FOREIGN KEY (ShipVia) REFERENCES dbo.Staging_Shippers(ShipperID),
    CONSTRAINT FK_Orders_Territories FOREIGN KEY (TerritoryID) REFERENCES dbo.Staging_Territories(TerritoryID)
);

-- Products Table
CREATE TABLE dbo.Staging_Products (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT UNIQUE,
    ProductName NVARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(10,2),
    UnitsInStock SMALLINT,
    UnitsOnOrder SMALLINT,
    ReorderLevel SMALLINT,
    Discontinued BIT,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Staging_Categories(CategoryID),
    CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierID) REFERENCES dbo.Staging_Suppliers(SupplierID)
);


-- Order Details Table
CREATE TABLE dbo.Staging_OrderDetails (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT UNIQUE,
    ProductID INT,
    UnitPrice DECIMAL(10,2),
    Quantity SMALLINT,
    Discount FLOAT,
    CONSTRAINT FK_OrderDetails_OrderID FOREIGN KEY (OrderID) REFERENCES dbo.Staging_Orders(OrderID),
    CONSTRAINT FK_OrderDetails_ProductID FOREIGN KEY (ProductID) REFERENCES dbo.Staging_Products(ProductID)
);

-- Region Table
CREATE TABLE dbo.Staging_Region (
    staging_raw_id INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT UNIQUE,
    RegionDescription NVARCHAR(255),
    RegionCategory NVARCHAR(255),
    RegionImportance NVARCHAR(255)
);



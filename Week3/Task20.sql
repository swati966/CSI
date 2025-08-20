
-- TASK 20
IF OBJECT_ID('dbo.SourceProducts', 'U') IS NOT NULL
    DROP TABLE dbo.SourceProducts;

IF OBJECT_ID('dbo.TargetProducts', 'U') IS NOT NULL
    DROP TABLE dbo.TargetProducts;

CREATE TABLE dbo.SourceProducts (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    LastStockDate DATE DEFAULT GETDATE()
);


CREATE TABLE dbo.TargetProducts (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    LastStockDate DATE,
    DateAdded DATETIME DEFAULT GETDATE()
);


INSERT INTO dbo.SourceProducts (ProductID, ProductName, Price) VALUES
(101, 'Wireless Mouse', 24.99),
(102, 'Mechanical Keyboard', 89.99),
(103, 'HD Webcam', 59.99),
(104, 'Noise-Canceling Headphones', 199.99);


INSERT INTO dbo.TargetProducts (ProductID, ProductName, Price, LastStockDate) VALUES
(101, 'Wireless Mouse', 24.99, '2023-05-15'), -- Existing product
(105, 'Bluetooth Speaker', 129.99, '2023-06-01'); -- Product not in source


INSERT INTO dbo.TargetProducts (ProductID, ProductName, Price, LastStockDate)
SELECT 
    s.ProductID,
    s.ProductName,
    s.Price,
    s.LastStockDate
FROM 
    dbo.SourceProducts s
LEFT JOIN 
    dbo.TargetProducts t ON s.ProductID = t.ProductID
WHERE 
    t.ProductID IS NULL; -- Only records that don't exist in target

SELECT 
    'Source Table' AS TableName,
    ProductID,
    ProductName,
    Price,
    LastStockDate
FROM 
    dbo.SourceProducts
UNION ALL
SELECT 
    'Target Table' AS TableName,
    ProductID,
    ProductName,
    Price,
    LastStockDate
FROM 
    dbo.TargetProducts
ORDER BY 
    TableName DESC, ProductID;


SELECT 
    s.ProductID,
    s.ProductName,
    s.Price,
    s.LastStockDate,
    'Copied to target' AS Status
FROM 
    dbo.SourceProducts s
INNER JOIN 
    dbo.TargetProducts t ON s.ProductID = t.ProductID
WHERE 
    t.DateAdded >= DATEADD(MINUTE, -5, GETDATE()) -- Records added in last 5 minutes
UNION ALL
SELECT 
    ProductID,
    ProductName,
    Price,
    LastStockDate,
    'Already existed' AS Status
FROM 
    dbo.TargetProducts
WHERE 
    DateAdded < DATEADD(MINUTE, -5, GETDATE());
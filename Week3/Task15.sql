
IF OBJECT_ID('dbo.EmployeeData', 'U') IS NOT NULL
    DROP TABLE dbo.EmployeeData;

CREATE TABLE dbo.EmployeeData (
    ID INT PRIMARY KEY,
    FullName NVARCHAR(100),
    MonthlySalary DECIMAL(10,2),
    Department NVARCHAR(50)
);

INSERT INTO dbo.EmployeeData (ID, FullName, MonthlySalary, Department) VALUES
(101, 'John Smith', 85000.00, 'Engineering'),
(102, 'Sarah Johnson', 92000.00, 'Marketing'),
(103, 'Michael Brown', 78000.00, 'Engineering'),
(104, 'Emily Davis', 110000.00, 'Finance'),
(105, 'Robert Wilson', 95000.00, 'HR'),
(106, 'Jennifer Lee', 105000.00, 'Finance'),
(107, 'David Miller', 88000.00, 'Engineering'),
(108, 'Jessica Taylor', 115000.00, 'Executive'),
(109, 'Daniel Anderson', 82000.00, 'Marketing'),
(110, 'Lisa Martinez', 98000.00, 'HR');


SELECT * FROM dbo.EmployeeData;


SELECT 
    ID,
    FullName,
    MonthlySalary,
    Department
FROM (
    SELECT 
        ID,
        FullName,
        MonthlySalary,
        Department,
        DENSE_RANK() OVER (ORDER BY MonthlySalary DESC) AS SalaryRank
    FROM dbo.EmployeeData
) AS RankedEmployees
WHERE SalaryRank <= 5;

-- Method 2: Using TOP in a subquery
SELECT *
FROM dbo.EmployeeData
WHERE MonthlySalary IN (
    SELECT DISTINCT TOP 5 MonthlySalary
    FROM dbo.EmployeeData
    ORDER BY MonthlySalary DESC
);
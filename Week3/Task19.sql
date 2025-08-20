-- TASK 19
IF OBJECT_ID('dbo.EMPLOYEES', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.EMPLOYEES (
        ID INT PRIMARY KEY,
        NAME VARCHAR(100),
        SALARY INT
    );
    
   
    INSERT INTO dbo.EMPLOYEES VALUES
    (1, 'John', 10020),
    (2, 'Sarah', 12050),
    (3, 'Mike', 10000),
    (4, 'Emily', 20500),
    (5, 'David', 15080);
END
GO

SELECT 
    CEILING(
        AVG(SALARY) - 
        AVG(CAST(REPLACE(CAST(SALARY AS VARCHAR), '0', '') AS DECIMAL(10,2)))
    ) AS Salary_Error
FROM 
    dbo.EMPLOYEES;
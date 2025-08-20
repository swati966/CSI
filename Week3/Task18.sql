-- TASK 18: 
IF OBJECT_ID('dbo.EmployeeCosts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.EmployeeCosts (
        EmployeeID INT,
        EmployeeName VARCHAR(100),
        BusinessUnit VARCHAR(50),
        Cost DECIMAL(18,2), 
        EffectiveDate DATE,
        EndDate DATE NULL 
    );
    
   
    INSERT INTO dbo.EmployeeCosts VALUES
    
    (101, 'John Smith', 'Engineering', 5000, '2023-01-01', '2023-06-30'),
    (102, 'Sarah Lee', 'Engineering', 5500, '2023-01-01', '2023-03-31'),
    (102, 'Sarah Lee', 'Engineering', 6000, '2023-04-01', NULL),
    (103, 'Mike Brown', 'Engineering', 5200, '2023-01-01', NULL),
    
   
    (201, 'Emily Chen', 'Marketing', 4800, '2023-01-01', '2023-02-28'),
    (201, 'Emily Chen', 'Marketing', 5300, '2023-03-01', NULL),
    (202, 'David Wilson', 'Marketing', 5100, '2023-01-01', NULL),
    
    (301, 'Lisa Taylor', 'Finance', 6200, '2023-01-01', NULL),
    (302, 'Robert Johnson', 'Finance', 5800, '2023-01-01', '2023-05-31');
END
GO


WITH MonthlyData AS (
    SELECT 
        DATEFROMPARTS(YEAR(d.[Date]), MONTH(d.[Date]), 1) AS MonthStart,
        c.BusinessUnit,
        c.EmployeeID,
        c.EmployeeName,
        c.Cost
    FROM 
        dbo.EmployeeCosts c
    CROSS JOIN (
        
        SELECT DISTINCT DATEADD(MONTH, n, '2023-01-01') AS [Date]
        FROM (
            SELECT TOP 12 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
            FROM sys.objects
        ) nums
    ) d
    WHERE 
        d.[Date] BETWEEN c.EffectiveDate AND ISNULL(c.EndDate, '9999-12-31')
),
WeightedCosts AS (
    SELECT
        BusinessUnit,
        MonthStart,
        SUM(Cost) AS TotalCost,
        COUNT(EmployeeID) AS EmployeeCount,
        SUM(Cost) / COUNT(EmployeeID) AS WeightedAvgCost,
        
        LAG(SUM(Cost) / COUNT(EmployeeID)) OVER (PARTITION BY BusinessUnit ORDER BY MonthStart) AS PrevMonthAvgCost
    FROM 
        MonthlyData
    GROUP BY
        BusinessUnit,
        MonthStart
)
SELECT
    BusinessUnit AS [Business Unit],
    FORMAT(MonthStart, 'yyyy-MM') AS [Month],
    EmployeeCount AS [Headcount],
    FORMAT(TotalCost, 'N0') AS [Total Cost],
    FORMAT(WeightedAvgCost, 'N2') AS [Weighted Avg Cost],
    CASE
        WHEN PrevMonthAvgCost IS NULL THEN 'N/A'
        WHEN WeightedAvgCost > PrevMonthAvgCost THEN 
            FORMAT((WeightedAvgCost - PrevMonthAvgCost) / PrevMonthAvgCost, '+0.00%')
        ELSE 
            FORMAT((WeightedAvgCost - PrevMonthAvgCost) / PrevMonthAvgCost, '0.00%')
    END AS [MoM Change]
FROM
    WeightedCosts
ORDER BY
    BusinessUnit,
    MonthStart;
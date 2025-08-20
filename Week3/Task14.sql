-- TASK 14

IF OBJECT_ID('dbo.Employees', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Employees (
        employee_id INT PRIMARY KEY,
        employee_name VARCHAR(100),
        sub_band VARCHAR(50),
        department VARCHAR(50),
        hire_date DATE
    );
    
    
    INSERT INTO dbo.Employees VALUES
    (101, 'John Smith', 'B1', 'Engineering', '2020-01-15'),
    (102, 'Sarah Johnson', 'B2', 'Engineering', '2019-05-22'),
   
    (150, 'Michael Brown', 'B5', 'Finance', '2023-02-10');
END
GO


WITH SubBandStats AS (
    SELECT
        sub_band,
        COUNT(*) AS headcount,
        SUM(COUNT(*)) OVER () AS total_headcount,
        
        CAST(COUNT(*) AS FLOAT) / SUM(COUNT(*)) OVER () * 100 AS percentage
    FROM dbo.Employees
    GROUP BY sub_band
)
SELECT
    sub_band AS [Sub-band],
    headcount AS [Headcount],
    FORMAT(percentage, 'N1') + '%' AS [Percentage],
   
    REPLICATE('*', ROUND(percentage, 0)) AS [Distribution Chart],
   
    FIRST_VALUE(headcount) OVER (ORDER BY headcount DESC) AS [Highest Band Count],
    LAST_VALUE(headcount) OVER (ORDER BY headcount DESC 
                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [Lowest Band Count],
    AVG(headcount) OVER () AS [Avg Band Count]
FROM SubBandStats
ORDER BY 
    CASE 
        WHEN sub_band LIKE 'B[0-9]' THEN CAST(SUBSTRING(sub_band, 2, 1) AS INT)
        ELSE 99 
    END; 
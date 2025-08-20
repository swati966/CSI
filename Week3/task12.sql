
IF OBJECT_ID('dbo.JobCosts', 'U') IS NOT NULL
    DROP TABLE dbo.JobCosts;

CREATE TABLE dbo.JobCosts (
    job_family VARCHAR(50),
    country VARCHAR(50),
    cost DECIMAL(18,2)
);


INSERT INTO dbo.JobCosts VALUES
('Engineering', 'India', 50000),
('Engineering', 'USA', 30000),
('Marketing', 'India', 20000),
('Marketing', 'UK', 40000),
('Sales', 'France', 35000),
('Sales', 'India', 15000);


;
WITH CostSummary AS (
    SELECT 
        job_family,
        SUM(CASE 
            WHEN UPPER(country) = 'INDIA' THEN cost 
            WHEN country LIKE 'IN%' THEN cost
            ELSE 0 
        END) AS india_cost,
        SUM(CASE 
            WHEN UPPER(country) != 'INDIA' AND NOT country LIKE 'IN%' THEN cost 
            ELSE 0 
        END) AS international_cost,
        SUM(cost) AS total_cost
    FROM 
        dbo.JobCosts
    GROUP BY 
        job_family
)
SELECT 
    job_family AS [Job Family],
    CONCAT(ROUND((india_cost * 100.0) / NULLIF(total_cost, 0), 1), '%') AS [India %],
    CONCAT(ROUND((international_cost * 100.0) / NULLIF(total_cost, 0), 1), '%') AS [International %],
    FORMAT(india_cost, 'N0') AS [India Cost],
    FORMAT(international_cost, 'N0') AS [International Cost],
    FORMAT(total_cost, 'N0') AS [Total Cost]
FROM 
    CostSummary
ORDER BY 
    job_family;
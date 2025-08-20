-- TASK 13

IF OBJECT_ID('dbo.BusinessUnitFinancials', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BusinessUnitFinancials (
        report_date DATE,
        business_unit VARCHAR(50),
        cost DECIMAL(18,2),
        revenue DECIMAL(18,2),
        CONSTRAINT PK_BusinessUnitFinancials PRIMARY KEY (report_date, business_unit)
    );
    
    
    INSERT INTO dbo.BusinessUnitFinancials VALUES
    ('2023-01-31', 'Marketing', 125000, 150000),
    ('2023-01-31', 'Sales', 200000, 300000),
    ('2023-01-31', 'Engineering', 350000, 400000),
    ('2023-02-28', 'Marketing', 135000, 170000),
    ('2023-02-28', 'Sales', 210000, 320000),
    ('2023-02-28', 'Engineering', 340000, 420000),
    ('2023-03-31', 'Marketing', 140000, 180000),
    ('2023-03-31', 'Sales', 220000, 350000),
    ('2023-03-31', 'Engineering', 360000, 450000),
    ('2023-04-30', 'Marketing', 130000, 160000),
    ('2023-04-30', 'Sales', 230000, 380000),
    ('2023-04-30', 'Engineering', 370000, 470000),
    ('2023-05-31', 'Marketing', 120000, 155000),
    ('2023-05-31', 'Sales', 240000, 400000),
    ('2023-05-31', 'Engineering', 380000, 500000),
    ('2023-06-30', 'Marketing', 110000, 145000),
    ('2023-06-30', 'Sales', 250000, 420000),
    ('2023-06-30', 'Engineering', 390000, 520000);
END
GO


WITH MonthlyData AS (
    SELECT
        business_unit,
        YEAR(report_date) AS report_year,
        MONTH(report_date) AS report_month,
        report_date,
        cost,
        revenue,
      
        cost / NULLIF(revenue, 0) AS cost_revenue_ratio
    FROM dbo.BusinessUnitFinancials
),
MoMComparison AS (
    SELECT
        business_unit,
        report_year,
        report_month,
        report_date,
        cost,
        revenue,
        cost_revenue_ratio,
        LAG(report_date) OVER (PARTITION BY business_unit ORDER BY report_date) AS prev_report_date,
        LAG(cost) OVER (PARTITION BY business_unit ORDER BY report_date) AS prev_cost,
        LAG(revenue) OVER (PARTITION BY business_unit ORDER BY report_date) AS prev_revenue,
        LAG(cost_revenue_ratio) OVER (PARTITION BY business_unit ORDER BY report_date) AS prev_ratio
    FROM MonthlyData
)
SELECT
    business_unit AS [Business Unit],
    FORMAT(report_date, 'yyyy-MM') AS [Month],
    FORMAT(cost, 'N0') AS [Cost],
    FORMAT(revenue, 'N0') AS [Revenue],
    FORMAT(cost_revenue_ratio, 'P1') AS [Cost/Revenue Ratio],
    -- Month-over-month changes
    CASE
        WHEN prev_ratio IS NULL THEN 'N/A'
        WHEN cost_revenue_ratio > prev_ratio THEN FORMAT(cost_revenue_ratio - prev_ratio, '+0.0%;-0.0%')
        ELSE FORMAT(cost_revenue_ratio - prev_ratio, '0.0%')
    END AS [MoM Ratio Change],
    CASE
        WHEN prev_cost IS NULL THEN 'N/A'
        WHEN cost > prev_cost THEN FORMAT((cost - prev_cost)/prev_cost, '+0.0%;-0.0%')
        ELSE FORMAT((cost - prev_cost)/prev_cost, '0.0%')
    END AS [MoM Cost Change],
    CASE
        WHEN prev_revenue IS NULL THEN 'N/A'
        WHEN revenue > prev_revenue THEN FORMAT((revenue - prev_revenue)/prev_revenue, '+0.0%;-0.0%')
        ELSE FORMAT((revenue - prev_revenue)/prev_revenue, '0.0%')
    END AS [MoM Revenue Change]
FROM MoMComparison
ORDER BY
    business_unit,
    report_date;
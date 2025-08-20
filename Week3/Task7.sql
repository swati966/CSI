--Task7
WITH Numbers AS (

    SELECT 2 AS num
    UNION ALL
    SELECT num + 1 FROM Numbers WHERE num < 1000
),
Primes AS (
    
    SELECT n1.num AS prime
    FROM Numbers n1
    WHERE NOT EXISTS (
        SELECT 1 FROM Numbers n2 
        WHERE n2.num > 1 AND n2.num < n1.num AND n1.num % n2.num = 0
    )
)

SELECT STRING_AGG(CAST(prime AS VARCHAR), '&') WITHIN GROUP (ORDER BY prime) AS primes
FROM Primes
OPTION (MAXRECURSION 1000);  
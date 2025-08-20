
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Functions')
BEGIN
    CREATE TABLE Functions (
        X INT,
        Y INT
    );
    PRINT 'Functions table created successfully.';
END
ELSE
BEGIN
    PRINT 'Functions table already exists.';
END

TRUNCATE TABLE Functions;


INSERT INTO Functions (X, Y) VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);


SELECT * FROM Functions ORDER BY X, Y;


WITH SymmetricPairs AS (
   
    SELECT f1.X, f1.Y
    FROM Functions f1
    JOIN Functions f2 ON f1.X = f2.Y AND f1.Y = f2.X
    WHERE f1.X < f1.Y
    
    UNION
    
  
    SELECT X, Y
    FROM Functions
    WHERE X = Y
    GROUP BY X, Y
    HAVING COUNT(*) > 1
)
SELECT X, Y
FROM SymmetricPairs
ORDER BY X, Y;
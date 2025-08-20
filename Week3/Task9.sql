--Task9
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BST' AND type = 'U')
BEGIN
    CREATE TABLE BST (
        N INT,
        P INT
    );
    PRINT 'BST table created successfully.';
END
ELSE
BEGIN
    PRINT 'BST table already exists.';
END
GO


DELETE FROM BST;
GO


INSERT INTO BST (N, P) VALUES
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, 5),
(8, 5),
(5, NULL); 
GO

SELECT
    N,
    CASE 
        WHEN P IS NULL THEN 'Root'
        WHEN N IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Inner'
        ELSE 'Leaf'
    END AS NodeType
FROM BST
ORDER BY N;
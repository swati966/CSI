--Task 8
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OCCUPATIONS' AND type = 'U')
BEGIN
    CREATE TABLE OCCUPATIONS (
        Name VARCHAR(50),
        Occupation VARCHAR(20)
    );
    PRINT 'OCCUPATIONS table created successfully.';
END
ELSE
BEGIN
    PRINT 'OCCUPATIONS table already exists.';
END
GO


DELETE FROM OCCUPATIONS;
GO

INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashely', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');
GO


WITH NumberedOccupations AS (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM OCCUPATIONS
)
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM NumberedOccupations
GROUP BY RowNum
ORDER BY RowNum;
--Task2
-- Students table
CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

-- Friends table
CREATE TABLE Friends (
    ID INT,
    Friend_ID INT,
    PRIMARY KEY (ID)
);

-- Packages table
CREATE TABLE Packages (
    ID INT,
    Salary FLOAT,
    PRIMARY KEY (ID)
);

INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);


INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID
JOIN Packages p2 ON f.Friend_ID = p2.ID
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;
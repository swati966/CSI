-- Task5
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Hackers' AND type = 'U')
BEGIN
    CREATE TABLE Hackers (
        hacker_id INT PRIMARY KEY,
        name VARCHAR(100)
    );
    PRINT 'Hackers table created successfully.';
END
ELSE
BEGIN
    PRINT 'Hackers table already exists.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Submissions' AND type = 'U')
BEGIN
    CREATE TABLE Submissions (
        submission_date DATE,
        submission_id INT,
        hacker_id INT,
        score INT,
        FOREIGN KEY (hacker_id) REFERENCES Hackers(hacker_id)
    );
    PRINT 'Submissions table created successfully.';
END
ELSE
BEGIN
    PRINT 'Submissions table already exists.';
END
GO

-- Clear existing data if needed
DELETE FROM Submissions;
DELETE FROM Hackers;
GO

-- Insert sample data into Hackers
INSERT INTO Hackers (hacker_id, name) VALUES
(15758, 'Rose'),
(20703, 'Angela'),
(36396, 'Frank'),
(38289, 'Patrick'),
(44065, 'Lisa'),
(53473, 'Kimberly'),
(62529, 'Bonnie'),
(79722, 'Michael');
GO


INSERT INTO Submissions (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);
GO

WITH DailyCounts AS (
  
    SELECT 
        submission_date,
        hacker_id,
        COUNT(*) AS submissions_count
    FROM Submissions
    GROUP BY submission_date, hacker_id
),
DailyMax AS (

    SELECT 
        submission_date,
        hacker_id,
        ROW_NUMBER() OVER (
            PARTITION BY submission_date 
            ORDER BY submissions_count DESC, hacker_id
        ) AS rn
    FROM DailyCounts
),
ConsecutiveDays AS (
  
    SELECT 
        s.submission_date,
        s.hacker_id,
        DATEDIFF(day, '2016-03-01', s.submission_date) + 1 AS day_number,
        COUNT(DISTINCT s2.submission_date) AS consecutive_days
    FROM 
        (SELECT DISTINCT submission_date, hacker_id FROM Submissions) s
        CROSS APPLY (
            SELECT s2.submission_date
            FROM Submissions s2
            WHERE s2.hacker_id = s.hacker_id
              AND s2.submission_date <= s.submission_date
            GROUP BY s2.submission_date
        ) s2
    GROUP BY s.submission_date, s.hacker_id
)
SELECT 
    d.submission_date,
    COUNT(DISTINCT CASE WHEN cd.consecutive_days = cd.day_number 
                   THEN cd.hacker_id END) AS unique_hackers,
    dm.hacker_id,
    h.name
FROM 
    (SELECT DISTINCT submission_date FROM Submissions) d
    LEFT JOIN ConsecutiveDays cd ON d.submission_date = cd.submission_date
    LEFT JOIN DailyMax dm ON d.submission_date = dm.submission_date AND dm.rn = 1
    LEFT JOIN Hackers h ON dm.hacker_id = h.hacker_id
GROUP BY 
    d.submission_date, dm.hacker_id, h.name
ORDER BY 
    d.submission_date;
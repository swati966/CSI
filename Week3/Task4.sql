--TASK4
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Contests' AND type = 'U')
BEGIN
    CREATE TABLE Contests (
        contest_id INT PRIMARY KEY,
        hacker_id INT,
        name VARCHAR(100)
    );
    PRINT 'Contests table created successfully.';
END
ELSE
BEGIN
    PRINT 'Contests table already exists.';
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Colleges' AND type = 'U')
BEGIN
    CREATE TABLE Colleges (
        college_id INT PRIMARY KEY,
        contest_id INT,
        FOREIGN KEY (contest_id) REFERENCES Contests(contest_id)
    );
    PRINT 'Colleges table created successfully.';
END
ELSE
BEGIN
    PRINT 'Colleges table already exists.';
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Challenges' AND type = 'U')
BEGIN
    CREATE TABLE Challenges (
        challenge_id INT PRIMARY KEY,
        college_id INT,
        FOREIGN KEY (college_id) REFERENCES Colleges(college_id)
    );
    PRINT 'Challenges table created successfully.';
END
ELSE
BEGIN
    PRINT 'Challenges table already exists.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'View_Stats' AND type = 'U')
BEGIN
    CREATE TABLE View_Stats (
        challenge_id INT,
        total_views INT,
        total_unique_views INT,
        FOREIGN KEY (challenge_id) REFERENCES Challenges(challenge_id)
    );
    PRINT 'View_Stats table created successfully.';
END
ELSE
BEGIN
    PRINT 'View_Stats table already exists.';
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Submission_Stats' AND type = 'U')
BEGIN
    CREATE TABLE Submission_Stats (
        challenge_id INT,
        total_submissions INT,
        total_accepted_submissions INT,
        FOREIGN KEY (challenge_id) REFERENCES Challenges(challenge_id)
    );
    PRINT 'Submission_Stats table created successfully.';
END
ELSE
BEGIN
    PRINT 'Submission_Stats table already exists.';
END
GO


DELETE FROM Submission_Stats;
DELETE FROM View_Stats;
DELETE FROM Challenges;
DELETE FROM Colleges;
DELETE FROM Contests;
GO


INSERT INTO Contests (contest_id, hacker_id, name) VALUES 
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');
GO


INSERT INTO Colleges (college_id, contest_id) VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);  
GO


INSERT INTO Challenges (challenge_id, college_id) VALUES
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685),
(75516, 56685); 
GO

INSERT INTO View_Stats (challenge_id, total_views, total_unique_views) VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);
GO


INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions) VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);
GO

WITH SubmissionAgg AS (
    SELECT 
        challenge_id, 
        SUM(total_submissions) AS total_submissions,
        SUM(total_accepted_submissions) AS total_accepted_submissions
    FROM Submission_Stats
    GROUP BY challenge_id
),
ViewAgg AS (
    SELECT 
        challenge_id, 
        SUM(total_views) AS total_views,
        SUM(total_unique_views) AS total_unique_views
    FROM View_Stats
    GROUP BY challenge_id
)
SELECT 
    c.contest_id, 
    c.hacker_id, 
    c.name,
    COALESCE(SUM(s.total_submissions), 0) AS total_submissions,
    COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions,
    COALESCE(SUM(v.total_views), 0) AS total_views,
    COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views
FROM 
    Contests c
    JOIN Colleges col ON c.contest_id = col.contest_id
    JOIN Challenges ch ON col.college_id = ch.college_id
    LEFT JOIN SubmissionAgg s ON ch.challenge_id = s.challenge_id
    LEFT JOIN ViewAgg v ON ch.challenge_id = v.challenge_id
GROUP BY 
    c.contest_id, c.hacker_id, c.name
HAVING 
    COALESCE(SUM(s.total_submissions), 0) + 
    COALESCE(SUM(s.total_accepted_submissions), 0) + 
    COALESCE(SUM(v.total_views), 0) + 
    COALESCE(SUM(v.total_unique_views), 0) > 0
ORDER BY 
    c.contest_id;
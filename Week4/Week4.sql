
IF OBJECT_ID('Allotments', 'U') IS NOT NULL DROP TABLE Allotments;
IF OBJECT_ID('UnallotedStudents', 'U') IS NOT NULL DROP TABLE UnallotedStudents;
IF OBJECT_ID('StudentPreference', 'U') IS NOT NULL DROP TABLE StudentPreference;
IF OBJECT_ID('SubjectDetails', 'U') IS NOT NULL DROP TABLE SubjectDetails;
IF OBJECT_ID('StudentDetails', 'U') IS NOT NULL DROP TABLE StudentDetails;
IF OBJECT_ID('AllocateOpenElectives', 'P') IS NOT NULL DROP PROCEDURE AllocateOpenElectives;
GO


CREATE TABLE StudentDetails (
    StudentId VARCHAR(9) PRIMARY KEY,
    StudentName VARCHAR(50),
    GPA DECIMAL(3,1),
    Branch VARCHAR(10),
    Section CHAR(1)
);

CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);

CREATE TABLE StudentPreference (
    StudentId VARCHAR(9),
    SubjectId VARCHAR(10),
    Preference INT,
    PRIMARY KEY (StudentId, SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);
GO


INSERT INTO StudentDetails (StudentId, StudentName, GPA, Branch, Section) VALUES
('159103036', 'Mohit Agarwal', 8.9, 'CCE', 'A'),
('159103037', 'Rohit Agarwal', 5.2, 'CCE', 'A'),
('159103038', 'Shohit Garg', 7.1, 'CCE', 'B'),
('159103039', 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
('159103040', 'Mehreet Singh', 5.6, 'CCE', 'A'),
('159103041', 'Arjun Tehlan', 9.2, 'CCE', 'B');


INSERT INTO SubjectDetails (SubjectId, SubjectName, MaxSeats, RemainingSeats) VALUES
('PO1491', 'Basics of Political Science', 60, 1), 
('PO1492', 'Basics of Accounting', 120, 120),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 60),
('PO1495', 'Automotive Trends', 60, 60);

INSERT INTO StudentPreference (StudentId, SubjectId, Preference) VALUES

('159103036', 'PO1491', 1),
('159103036', 'PO1492', 2),
('159103036', 'PO1493', 3),
('159103036', 'PO1494', 4),
('159103036', 'PO1495', 5),

('159103041', 'PO1491', 1), 
('159103041', 'PO1492', 2),
('159103041', 'PO1493', 3),
('159103041', 'PO1494', 4),
('159103041', 'PO1495', 5),

('159103037', 'PO1492', 1),
('159103038', 'PO1493', 1),
('159103039', 'PO1494', 1),
('159103040', 'PO1495', 1);
GO


CREATE TABLE Allotments (
    SubjectId VARCHAR(10),
    StudentId VARCHAR(9),
    PRIMARY KEY (SubjectId, StudentId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);

CREATE TABLE UnallotedStudents (
    StudentId VARCHAR(9) PRIMARY KEY,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);
GO


CREATE PROCEDURE AllocateOpenElectives
AS
BEGIN
    
    TRUNCATE TABLE Allotments;
    TRUNCATE TABLE UnallotedStudents;
    
  
    DECLARE @SubjectCapacity TABLE (
        SubjectId VARCHAR(10),
        RemainingSeats INT
    );
    
    INSERT INTO @SubjectCapacity
    SELECT SubjectId, RemainingSeats FROM SubjectDetails;
    
   
    DECLARE @StudentsToProcess TABLE (
        StudentId VARCHAR(9),
        GPA DECIMAL(3,1),
        RowNum INT
    );
    
    INSERT INTO @StudentsToProcess
    SELECT StudentId, GPA, ROW_NUMBER() OVER (ORDER BY GPA DESC) 
    FROM StudentDetails;
    
    DECLARE @TotalStudents INT = (SELECT COUNT(*) FROM @StudentsToProcess);
    DECLARE @CurrentStudent INT = 1;
    
    WHILE @CurrentStudent <= @TotalStudents
    BEGIN
        DECLARE @StudentId VARCHAR(9) = (SELECT StudentId FROM @StudentsToProcess WHERE RowNum = @CurrentStudent);
        DECLARE @Allotted BIT = 0;
        DECLARE @Preference INT = 1;
        
        WHILE @Preference <= 5 AND @Allotted = 0
        BEGIN
            DECLARE @SubjectId VARCHAR(10) = (
                SELECT SubjectId 
                FROM StudentPreference 
                WHERE StudentId = @StudentId AND Preference = @Preference
            );
            
            IF @SubjectId IS NOT NULL AND EXISTS (
                SELECT 1 FROM @SubjectCapacity 
                WHERE SubjectId = @SubjectId AND RemainingSeats > 0
            )
            BEGIN
                INSERT INTO Allotments VALUES (@SubjectId, @StudentId);
                UPDATE @SubjectCapacity SET RemainingSeats = RemainingSeats - 1 WHERE SubjectId = @SubjectId;
                SET @Allotted = 1;
            END
            
            SET @Preference = @Preference + 1;
        END
        
        IF @Allotted = 0
            INSERT INTO UnallotedStudents VALUES (@StudentId);
        
        SET @CurrentStudent = @CurrentStudent + 1;
    END
    

    UPDATE sd
    SET sd.RemainingSeats = sc.RemainingSeats
    FROM SubjectDetails sd
    JOIN @SubjectCapacity sc ON sd.SubjectId = sc.SubjectId;
END
GO


SELECT * FROM StudentDetails;
SELECT * FROM SubjectDetails;
SELECT * FROM StudentPreference;


EXEC AllocateOpenElectives;

SELECT SubjectId, StudentId FROM Allotments ORDER BY SubjectId, StudentId;
SELECT StudentId FROM UnallotedStudents ORDER BY StudentId;

SELECT * FROM SubjectDetails;
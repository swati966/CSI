-- Create STATION table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'STATION' AND type = 'U')
BEGIN
    CREATE TABLE STATION (
        ID INT PRIMARY KEY,
        CITY VARCHAR(21),
        STATE VARCHAR(2),
        LAT_N DECIMAL(10,6),
        LONG_W DECIMAL(10,6)
    );
    PRINT 'STATION table created successfully.';
END
ELSE
BEGIN
    PRINT 'STATION table already exists.';
END
GO


DELETE FROM STATION;
GO


INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES
(1, 'New York', 'NY', 40.7128, -74.0060),
(2, 'Los Angeles', 'CA', 34.0522, -118.2437),
(3, 'Chicago', 'IL', 41.8781, -87.6298),
(4, 'Houston', 'TX', 29.7604, -95.3698),
(5, 'Phoenix', 'AZ', 33.4484, -112.0740),
(6, 'Miami', 'FL', 25.7617, -80.1918),
(7, 'Seattle', 'WA', 47.6062, -122.3321),
(8, 'Denver', 'CO', 39.7392, -104.9903),
(9, 'Boston', 'MA', 42.3601, -71.0589),
(10, 'Atlanta', 'GA', 33.7490, -84.3880);
GO


INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES
(11, 'North Point', 'NP', 45.0000, -100.0000),
(12, 'South Point', 'SP', 35.0000, -80.0000),
(13, 'East Point', 'EP', 40.0000, -70.0000),
(14, 'West Point', 'WP', 40.0000, -110.0000);
GO

SELECT 
    CAST(ROUND(
        ABS(MIN(LAT_N) - MAX(LAT_N)) + 
        ABS(MIN(LONG_W) - MAX(LONG_W)), 
    4) AS DECIMAL(10,4)) AS Manhattan_Distance
FROM STATION;
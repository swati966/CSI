--Task16
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EmployeeData')
BEGIN
    PRINT 'EmployeeData table exists';
   
    SELECT 
        COLUMN_NAME AS ColumnName,
        DATA_TYPE AS DataType
    FROM 
        INFORMATION_SCHEMA.COLUMNS
    WHERE 
        TABLE_NAME = 'EmployeeData';
END
ELSE
BEGIN
    PRINT 'EmployeeData table does NOT exist - creating sample table';
    
    
    CREATE TABLE EmployeeData (
        ID INT PRIMARY KEY,
        FullName NVARCHAR(100),
        MonthlySalary DECIMAL(10,2),
        Department NVARCHAR(50)
    );
    
   
    INSERT INTO EmployeeData VALUES
    (1, 'John Smith', 50000.00, 'Engineering'),
    (2, 'Sarah Johnson', 65000.00, 'Marketing'),
    (3, 'Michael Brown', 72000.00, 'Finance');
    
    PRINT 'Sample EmployeeData table created with 3 records';
END


BEGIN TRY
   
    IF OBJECT_ID('tempdb..#SwapResults', 'U') IS NOT NULL
        DROP TABLE #SwapResults;
    
    SELECT 
        ID,
        FullName,
        MonthlySalary AS OriginalSalary,
        MonthlySalary * 1.1 AS NewSalary, 
        Department
    INTO 
        #SwapResults
    FROM 
        EmployeeData;
    
    SELECT * FROM #SwapResults;
    
    
    UPDATE #SwapResults
    SET 
        OriginalSalary = NewSalary,
        NewSalary = OriginalSalary;
    
    
    SELECT 
        ID,
        FullName,
        OriginalSalary AS [Salary After Swap],
        NewSalary AS [Original Value],
        Department
    FROM 
        #SwapResults;
    
    PRINT 'Swap operation completed successfully in temporary table';
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    PRINT 'Please verify:';
    PRINT '1. You have permissions on the database';
    PRINT '2. The EmployeeData table exists in your current database';
    PRINT '3. You are connected to the correct SQL Server instance';
END CATCH;
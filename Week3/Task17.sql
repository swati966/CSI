
-- TASK 17


DECLARE @LoginName NVARCHAR(128) = 'MasterAdmin_' + FORMAT(GETDATE(), 'yyyyMMdd');
DECLARE @Password NVARCHAR(128) = 'Master@' + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS NVARCHAR(10));
DECLARE @UserName NVARCHAR(128) = 'MasterAdmin_User';
DECLARE @DatabaseName NVARCHAR(128) = 'master';

BEGIN TRY

    USE [master];
    
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
    BEGIN
        EXEC('CREATE LOGIN [' + @LoginName + '] 
              WITH PASSWORD = ''' + @Password + ''',
              DEFAULT_DATABASE = [master],
              CHECK_EXPIRATION = OFF,
              CHECK_POLICY = ON');
        PRINT 'Login [' + @LoginName + '] created successfully in master';
    END
    ELSE
    BEGIN
        PRINT 'Login [' + @LoginName + '] already exists in master';
    END

   
    DECLARE @CreateUserSQL NVARCHAR(MAX) = '
    USE [master];
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''' + @UserName + ''')
    BEGIN
        CREATE USER [' + @UserName + '] FOR LOGIN [' + @LoginName + '];
        PRINT ''User [' + @UserName + '] created in [master]'';
    END
    ELSE
    BEGIN
        PRINT ''User [' + @UserName + '] already exists in [master]'';
    END';
    
    EXEC sp_executesql @CreateUserSQL;

   
    DECLARE @GrantPermissionSQL NVARCHAR(MAX) = '
    USE [master];
    BEGIN TRY
        ALTER ROLE [db_owner] ADD MEMBER [' + @UserName + '];
        PRINT ''DB_OWNER role granted to [' + @UserName + '] in [master]'';
    END TRY
    BEGIN CATCH
        PRINT ''ERROR granting db_owner: '' + ERROR_MESSAGE();
        PRINT ''Alternative: Trying with sp_addrolemember'';
        EXEC sp_addrolemember ''db_owner'', ''' + @UserName + ''';
    END CATCH';
    
    EXEC sp_executesql @GrantPermissionSQL;

 
    PRINT '================================';
    PRINT 'CREATED MASTER DB LOGIN WITH THESE DETAILS:';
    PRINT 'Login Name: ' + @LoginName;
    PRINT 'Password: ' + @Password;
    PRINT 'Database: master';
    PRINT '================================';

    
    SELECT 
        DB_NAME() AS DatabaseName,
        sp.name AS LoginName,
        dp.name AS UserName,
        dp.type_desc AS UserType,
        r.name AS RoleName
    FROM sys.database_principals dp
    JOIN sys.server_principals sp ON dp.sid = sp.sid
    LEFT JOIN sys.database_role_members rm ON dp.principal_id = rm.member_principal_id
    LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    WHERE dp.name = @UserName;
END TRY
BEGIN CATCH
    PRINT 'FINAL ERROR: ' + ERROR_MESSAGE();
    PRINT 'You must be logged in as a sysadmin to perform all these operations.';
    PRINT 'If you continue having issues, try:';
    PRINT '1. Connecting as sa or with sysadmin privileges';
    PRINT '2. Using SQL Server Authentication instead of Windows Auth if needed';
END CATCH;
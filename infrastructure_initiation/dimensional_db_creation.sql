USE master;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ORDER_DDS')
BEGIN
    ALTER DATABASE ORDER_DDS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ORDER_DDS;
    PRINT 'Database ORDER_DDS dropped successfully.';
END
ELSE
BEGIN
    PRINT 'Database ORDER_DDS does not exist. Proceeding to create it.';
END

CREATE DATABASE ORDER_DDS;
PRINT 'Database ORDER_DDS created successfully.';

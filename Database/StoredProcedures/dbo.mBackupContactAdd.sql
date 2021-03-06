/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mBackupContactAdd]

	@ContactBackupID INT OUTPUT,
	@UserID			 INT,
	@Priority		 INT,
	@ContactUserID	 INT,
	@ContactPhone	 NVARCHAR(50),
	@ContactEmail	 NVARCHAR(50)
	
AS 
    
	INSERT INTO dbo.ContactBackup
	(UserID, Priority, ContactUserID, ContactPhone, ContactEmail)
	VALUES
	(@UserID,@Priority,@ContactUserID,@ContactPhone,@ContactEmail)

	SET @ContactBackupID = @@IDENTITY

GO
GRANT EXECUTE ON [mBackupContactAdd] TO [db_dml]
GO

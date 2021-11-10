/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ContactBackupDeleteByUserID]
	@iUserID int

AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM ContactBackup
	WHERE UserID = @iUserID
END
GO
GRANT EXECUTE ON [ContactBackupDeleteByUserID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ContactBackupDeleteByUserID] TO [db_object_def_viewers]
GO

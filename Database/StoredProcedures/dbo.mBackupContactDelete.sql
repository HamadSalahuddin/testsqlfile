/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mBackupContactDelete]
	@ContactBackupID int	
AS
BEGIN

	DELETE FROM ContactBackup
	WHERE ContactBackupID = @ContactBackupID

END



GO
GRANT EXECUTE ON [mBackupContactDelete] TO [db_dml]
GO

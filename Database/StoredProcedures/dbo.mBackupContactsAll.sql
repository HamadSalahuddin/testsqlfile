/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mBackupContactsAll]
AS
BEGIN
SELECT cb.ContactBackupID, cb.UserID, cb.Priority, cb.ContactUserID, cb.ContactPhone, cb.ContactEmail,isnull(o.OfficerID,0)as OfficerID
	FROM ContactBackup cb left join officer o on cb.userid=o.userid	
END

GO
GRANT EXECUTE ON [mBackupContactsAll] TO [db_dml]
GO

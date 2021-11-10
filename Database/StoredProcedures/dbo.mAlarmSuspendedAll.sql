/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAlarmSuspendedAll]
	
AS
		SELECT *
		FROM AlarmSuspended
	    WHERE Deleted = 0 AND EndTime >= GETDATE()
	

GO
GRANT EXECUTE ON [mAlarmSuspendedAll] TO [db_dml]
GO
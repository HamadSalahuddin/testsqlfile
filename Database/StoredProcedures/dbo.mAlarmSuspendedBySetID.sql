/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAlarmSuspendedBySetID]

	@ProtocolEventID	INT

AS
		SELECT *
		FROM AlarmSuspended
		WHERE AlarmProtocolEventID=@ProtocolEventID AND 
              Deleted = 0
GO
GRANT EXECUTE ON [mAlarmSuspendedBySetID] TO [db_dml]
GO

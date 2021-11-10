/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StaticAlarmAssignmentsForAlarm] 
	@AlarmID bigint

AS

SELECT * FROM AlarmAssignment WHERE AlarmID=@AlarmID


GO
GRANT EXECUTE ON [StaticAlarmAssignmentsForAlarm] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [StaticAlarmAssignmentsForAlarm] TO [db_object_def_viewers]
GO
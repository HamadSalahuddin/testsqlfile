/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmAssignmentGetByAlarmAssignmentStatusID]
	@iAlarmAssignmentStatusID int

AS
BEGIN
	SELECT * 
	FROM AlarmAssignment
	WHERE AlarmAssignmentStatusID = @iAlarmAssignmentStatusID
END
GO
GRANT VIEW DEFINITION ON [AlarmAssignmentGetByAlarmAssignmentStatusID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [AlarmAssignmentGetByAlarmAssignmentStatusID] TO [db_dml]
GO

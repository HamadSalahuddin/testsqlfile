/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmAssignmentGetStatus]

	@AlarmAssignmentStatusID	INT OUTPUT,
	@AlarmID					INT
	
AS

SELECT TOP 1 @AlarmAssignmentStatusID = AlarmAssignmentStatusID
FROM AlarmAssignment
WHERE AlarmID = @AlarmID ORDER BY AlarmAssignmentStatusID DESC

IF @AlarmAssignmentStatusID IS NULL 
	SET @AlarmAssignmentStatusID =1
GO
GRANT EXECUTE ON [AlarmAssignmentGetStatus] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AlarmAssignmentGetStatus] TO [db_object_def_viewers]
GO

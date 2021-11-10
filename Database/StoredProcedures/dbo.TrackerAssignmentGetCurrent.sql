/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerAssignmentGetCurrent] 
	@TrackerID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (1)
		[TrackerAssignmentID],
		[TrackerID],[OffenderID],
		[SupervisionOfficerID],
		[AssignmentDate],
		[TrackerAssignmentTypeID],
		[CreatedBy],
		[CreatedDate]
	FROM 
		[TrackerAssignment]
	WHERE 
		TrackerID = @TrackerID
	ORDER BY 
		AssignmentDate DESC

END
GO
GRANT EXECUTE ON [TrackerAssignmentGetCurrent] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [TrackerAssignmentGetCurrent] TO [db_object_def_viewers]
GO

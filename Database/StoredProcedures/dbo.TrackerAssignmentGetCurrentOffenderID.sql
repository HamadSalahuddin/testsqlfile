/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerAssignmentGetCurrentOffenderID]
	@OffenderID int OUTPUT,
	@TrackerID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		@OffenderID = [OffenderID]
	FROM 
		[TrackerAssignment]
	WHERE 
		TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment WHERE TrackerID = @TrackerID)
		AND TrackerID = @TrackerID
		AND TrackerAssignmentTypeID = 1
END
GO
GRANT VIEW DEFINITION ON [TrackerAssignmentGetCurrentOffenderID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [TrackerAssignmentGetCurrentOffenderID] TO [db_dml]
GO

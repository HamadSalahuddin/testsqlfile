/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mTrackerUnassignment]
	@TrackerAssignmentID INT OUTPUT,
	@TrackerID INT,
	@OffenderID INT,
	@OfficerID INT,
	@AssignmentDate DATETIME OUTPUT,
	@CreatedByID INT

AS

SET @AssignmentDate = GETDATE()

INSERT INTO TrackerAssignment(
	TrackerID,
	OffenderID,
	SupervisionOfficerID,
	AssignmentDate,
	TrackerAssignmentTypeID,
	CreatedBy,
	CreatedDate
	)
VALUES(
	@TrackerID,
	@OffenderID,
	@OfficerID,
	@AssignmentDate,
	2,
	@CreatedByID,
	@AssignmentDate
	)

SET @TrackerAssignmentID = SCOPE_IDENTITY()


GO
GRANT EXECUTE ON [mTrackerUnassignment] TO [db_dml]
GO

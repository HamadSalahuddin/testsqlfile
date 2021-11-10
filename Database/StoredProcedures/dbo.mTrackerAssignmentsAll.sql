/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mTrackerAssignmentsAll]

	

AS
	select TrackerAssignmentID,TrackerID,OffenderID,SupervisionOfficerID,AssignmentDate,TrackerAssignmentTypeID,CreatedBy,CreatedDate
	from TrackerAssignment  
	
GO
GRANT EXECUTE ON [mTrackerAssignmentsAll] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ERuleUploadedTrackerIDUpdate]

	@ID	                   INT,
	@AssignedETrackerID    INT


AS
BEGIN

	UPDATE	 dbo.ERule
	SET		 AssignedETrackerID=@AssignedETrackerID	 	  
	WHERE	 ID = @ID

END







GO
GRANT EXECUTE ON [ERuleUploadedTrackerIDUpdate] TO [db_dml]
GO
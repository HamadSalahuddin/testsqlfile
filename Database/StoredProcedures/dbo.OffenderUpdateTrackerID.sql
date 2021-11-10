/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderUpdateTrackerID] 
	@OffenderID int = 0, 
	@TrackerID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Offender
	SET TrackerID = @TrackerID	
	WHERE OffenderID = @OffenderID

	SELECT @OffenderID, @TrackerID
END
GO
GRANT EXECUTE ON [OffenderUpdateTrackerID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderUpdateTrackerID] TO [db_object_def_viewers]
GO

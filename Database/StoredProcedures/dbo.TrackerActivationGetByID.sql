/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerActivationGetByID]

	@TrackerActivationID	INT

AS

	SELECT	*
	FROM	OffenderTrackerActivation ota
	WHERE	ota.TrackerActivationID = @TrackerActivationID

GO
GRANT EXECUTE ON [TrackerActivationGetByID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [TrackerActivationGetByID] TO [db_object_def_viewers]
GO

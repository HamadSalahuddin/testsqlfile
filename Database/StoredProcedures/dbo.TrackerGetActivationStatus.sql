/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerGetActivationStatus]
	@TrackerID	INT
AS

SELECT 
	ActivateDate,
	DeActivateDate
FROM 
	OffenderTrackerActivation
WHERE 
	ActivateDate = (SELECT MAX(ActivateDate) FROM OffenderTrackerActivation WHERE TrackerID = @TrackerID)
	AND DeActivateDate IS NULL
GO
GRANT EXECUTE ON [TrackerGetActivationStatus] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [TrackerGetActivationStatus] TO [db_object_def_viewers]
GO

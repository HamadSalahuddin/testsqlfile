/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmProtocolSetGetByAgencyIDOfficerID]

	@AgencyID INT,
	@OfficerID	INT

AS

	SELECT	AlarmProtocolSetID, AlarmProtocolSetName
	FROM	AlarmProtocolSet
	WHERE	(AgencyID = @AgencyID AND (OfficerID = 0 OR AlarmProtocolSetTypeID = 1))
			OR
			(OfficerID = @OfficerID)

	ORDER BY AlarmProtocolSetName


GO
GRANT VIEW DEFINITION ON [AlarmProtocolSetGetByAgencyIDOfficerID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [AlarmProtocolSetGetByAgencyIDOfficerID] TO [db_dml]
GO

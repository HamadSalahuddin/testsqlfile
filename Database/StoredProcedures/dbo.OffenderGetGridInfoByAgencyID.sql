/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetGridInfoByAgencyID]

	@AgencyID	INT

AS

	SELECT	o.OffenderID, o.FirstName, o.LastName, a.Agency
	FROM	Offender o
	LEFT JOIN Agency a ON o.AgencyID = a.AgencyID
	WHERE	a.AgencyID = @AgencyID
	ORDER BY a.Agency, o.LastName, o.FirstName



GO
GRANT EXECUTE ON [OffenderGetGridInfoByAgencyID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderGetGridInfoByAgencyID] TO [db_object_def_viewers]
GO

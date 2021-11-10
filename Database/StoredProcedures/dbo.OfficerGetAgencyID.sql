/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OfficerGetAgencyID]

	@AgencyID		INT OUTPUT,
	@UserID			INT

AS

	SELECT	@AgencyID = AgencyID
	FROM	Officer
	WHERE	UserID = @UserID
GO
GRANT VIEW DEFINITION ON [OfficerGetAgencyID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OfficerGetAgencyID] TO [db_dml]
GO
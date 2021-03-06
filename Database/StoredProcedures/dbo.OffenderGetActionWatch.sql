/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetActionWatch]
	@iAgencyID int,	
	@iUserID int

AS

	SELECT 
		oaw.OffenderID, 
		ISNULL(o.FirstName, '') + ' ' + ISNULL(o.MiddleName, '') + ' ' + ISNULL(o.LastName, '') AS 'OffenderName',
		oaw.AlarmOnTime
	FROM 
		OffenderActionWatch oaw
		JOIN Offender o ON o.OffenderID = oaw.OffenderID
	WHERE
		(
			(@iAgencyID<0)
			or
			(oaw.AgencyID = @iAgencyID)
		)
		and (
			(@iUserID<0)
			or
			(oaw.UserID = @iUserID)
		)
		and oaw.Enabled = 1
GO
GRANT EXECUTE ON [OffenderGetActionWatch] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderGetActionWatch] TO [db_object_def_viewers]
GO

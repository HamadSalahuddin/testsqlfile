/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TempGetAllOffendersNotAssingedADevice]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT o.OffenderID, ta.TrackerID, oo.OfficerID
	FROM Offender o
	LEFT JOIN TrackerAssignment ta ON ta.OffenderID = o.OffenderID
	LEFT JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
	WHERE ta.OffenderID IS NULL AND
		  o.Deleted = 'false'

END
GO
GRANT VIEW DEFINITION ON [TempGetAllOffendersNotAssingedADevice] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [TempGetAllOffendersNotAssingedADevice] TO [db_dml]
GO

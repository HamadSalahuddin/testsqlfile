/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleGetLibrary]
(@AgencyID int)
--WITH 
--EXECUTE AS CALLER
AS
SELECT
	g.*, s.*, 
	r.Street, r.City, r.StateID, r.PostalCode, r.CountryID, r.Latitude as 'RefLatitude', r.Longitude as 'RefLongitude',
	0 as ZoneID
FROM	GeoRule g --WITH (NOLOCK)
INNER JOIN GeoRule_Agency a ON g.GeoRuleID = a.GeoRuleID
LEFT JOIN GeoRuleSchedule s ON g.GeoRuleScheduleID = s.GeoRuleScheduleID
LEFT JOIN GEoRuleReferencePoint r ON g.GeoRuleReferencePointId = r.GeoRuleReferencePointId
WHERE	a.AgencyID = @AgencyID AND
	g.Deleted = 0 AND
	g.GeoRuleID NOT IN 
	(
		SELECT	GeoRuleID
		FROM	GeoRule_Offender
	)
ORDER BY g.GeoRuleName

GO
GRANT EXECUTE ON [GeoRuleGetLibrary] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerGetAssignedGeoRules]

	@TrackerID	INT

AS

SELECT 
	grofdr.[GeoRuleID]
FROM 
	[TrackerPal].[dbo].[TrackerAssignment] ta
	INNER JOIN GeoRule_Offender grofdr ON ta.OffenderID = grofdr.OffenderID AND TrackerAssignmentTypeID = 1
WHERE
	ta.TrackerID = @TrackerID
ORDER BY 
	ta.AssignmentDate DESC
GO
GRANT VIEW DEFINITION ON [TrackerGetAssignedGeoRules] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [TrackerGetAssignedGeoRules] TO [db_dml]
GO
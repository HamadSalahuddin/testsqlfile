/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AgencyGetGridInfo]

AS
SELECT	a.AgencyID, a.Agency, a.City, s.State
	FROM	Agency a
	LEFT JOIN State s ON a.StateID = s.StateID
	WHERE a.Deleted = 0
	ORDER BY a.Agency
GO
GRANT EXECUTE ON [AgencyGetGridInfo] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AgencyGetGridInfo] TO [db_object_def_viewers]
GO

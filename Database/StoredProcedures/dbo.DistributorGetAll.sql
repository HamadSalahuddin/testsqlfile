/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DistributorGetAll]
AS
	SELECT	d.DistributorID, d.DistributorName, d.City, s.State
	FROM	Distributor d(NOLOCK)
	LEFT JOIN State s ON d.StateID = s.StateID
    WHERE	deleted = 0
	ORDER BY DistributorName





GO
GRANT EXECUTE ON [DistributorGetAll] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [DistributorGetAll] TO [db_object_def_viewers]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [SuffixGetAll]

AS

	SELECT	SuffixID, Suffix
	FROM	Suffix
	ORDER BY Suffix
GO
GRANT EXECUTE ON [SuffixGetAll] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [SuffixGetAll] TO [db_object_def_viewers]
GO

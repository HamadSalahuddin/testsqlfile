/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StaticStatesGetAll]

AS

	SELECT	StateID, State, Abbreviation
	FROM	dbo.[State]

GO
GRANT VIEW DEFINITION ON [StaticStatesGetAll] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [StaticStatesGetAll] TO [db_dml]
GO

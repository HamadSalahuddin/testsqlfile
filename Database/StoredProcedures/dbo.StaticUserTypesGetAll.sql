/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StaticUserTypesGetAll]

AS

	SELECT	*
	FROM	[UserType] 

GO
GRANT EXECUTE ON [StaticUserTypesGetAll] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [StaticUserTypesGetAll] TO [db_object_def_viewers]
GO

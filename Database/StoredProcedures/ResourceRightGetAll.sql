/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ResourceRightGetAll]

AS

SET NOCOUNT ON

SELECT 0 AS HasAccess, ResourceID, Resource
FROM Resource
GO
GRANT VIEW DEFINITION ON [ResourceRightGetAll] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [ResourceRightGetAll] TO [db_dml]
GO

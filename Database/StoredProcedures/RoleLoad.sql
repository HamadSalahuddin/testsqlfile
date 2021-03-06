/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [RoleLoad]

@RoleID int

AS

SET NOCOUNT ON

SELECT r.[Role], rrm.ResourceID, rr.Resource
FROM [Role] r
INNER JOIN RoleResourceMap rrm ON r.RoleID = rrm.RoleID
INNER JOIN Resource rr ON rrm.ResourceID = rr.ResourceID
WHERE r.RoleID = @RoleID
GO
GRANT VIEW DEFINITION ON [RoleLoad] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [RoleLoad] TO [db_dml]
GO

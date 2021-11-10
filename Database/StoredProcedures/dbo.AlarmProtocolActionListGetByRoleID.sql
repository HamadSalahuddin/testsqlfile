/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmProtocolActionListGetByRoleID]

	@RoleID	INT

AS

	SELECT	AlarmProtocolActionListID, AlarmProtocolActionList
	FROM	AlarmProtocolActionList
	WHERE	RoleID <= @RoleID order by displayorder
GO
GRANT EXECUTE ON [AlarmProtocolActionListGetByRoleID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AlarmProtocolActionListGetByRoleID] TO [db_object_def_viewers]
GO

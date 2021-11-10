/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [User_RoleUpdate]

	@UserID		INT,
	@RoleID		INT

AS

	UPDATE 
		User_Role
	SET
		RoleID = @RoleID
	WHERE
		UserID = @UserID
GO
GRANT VIEW DEFINITION ON [User_RoleUpdate] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [User_RoleUpdate] TO [db_dml]
GO

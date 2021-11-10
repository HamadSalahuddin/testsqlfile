/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [UserUpdatePassword]

	@UserID			INT,
	@Password		NVARCHAR(50),
	@ModifiedByID	INT

AS

	UPDATE	[User]
	SET		UserPassword = @Password,
			ModifiedDate = GETDATE(),
			ModifiedByID = @ModifiedByID
	WHERE	UserID = @UserID
GO
GRANT EXECUTE ON [UserUpdatePassword] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [UserUpdatePassword] TO [db_object_def_viewers]
GO
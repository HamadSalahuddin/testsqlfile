/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [UserUpdateSessionTimeOut]
	@UserID			INT,
	@SessionTimeOut	INT,
	@ModifiedByID	INT
AS
	UPDATE	[User]
	SET		SessionTimeOut = @SessionTimeOut,
			ModifiedDate = GETDATE(),
			ModifiedByID = @ModifiedByID
	WHERE	UserID = @UserID

GO
GRANT EXECUTE ON [UserUpdateSessionTimeOut] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ChangePassword]
	(
		@UserID int,
		@NewPassword nvarchar(25)
	)
AS
	SET NOCOUNT ON
	
	Update [dbo].[User] SET [UserPassword] = @NewPassword WHERE [UserID] = @UserID

GO
GRANT VIEW DEFINITION ON [ChangePassword] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [ChangePassword] TO [db_dml]
GO

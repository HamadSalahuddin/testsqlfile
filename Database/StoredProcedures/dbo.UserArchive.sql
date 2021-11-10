/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [UserArchive]

	@UserID			INT,
	@ModifiedByID	INT,
	@ModifiedDate	DATETIME = NULL OUTPUT

AS

SET @ModifiedDate = GETDATE()

UPDATE	[User]
SET		ModifiedDate = @ModifiedDate,
		ModifiedByID = @ModifiedByID,
		Deleted = 1
WHERE	UserID = @UserID

GO
GRANT VIEW DEFINITION ON [UserArchive] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [UserArchive] TO [db_dml]
GO

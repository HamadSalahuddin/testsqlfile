/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AccessLevelGetByUserType]

	@UserTypeID	int

AS

	SET NOCOUNT ON

	SELECT	AccessLevelID, AccessLevel
	FROM	AccessLevel
	WHERE	UserTypeID = @UserTypeID
	ORDER BY AccessLevelID
GO
GRANT EXECUTE ON [AccessLevelGetByUserType] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AccessLevelGetByUserType] TO [db_object_def_viewers]
GO
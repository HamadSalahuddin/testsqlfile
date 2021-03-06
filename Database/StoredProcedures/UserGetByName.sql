/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [UserGetByName]
	@UserName nvarchar(50)
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM [User]
	WHERE UserName = @UserName and Deleted = 0;
END


GO
GRANT EXECUTE ON [UserGetByName] TO [db_dml]
GO

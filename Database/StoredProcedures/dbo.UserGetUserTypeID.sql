/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [UserGetUserTypeID]
    (@UserID int)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT u.UserTypeID   
 	FROM [User] u
 	WHERE u.UserID = @UserID 
        and u.Deleted = 0;    
END

GO
GRANT EXECUTE ON [UserGetUserTypeID] TO [db_dml]
GO

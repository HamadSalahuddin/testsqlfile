/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [RoleGetAdministrators]

AS

SELECT	
	opr.UserID, 
	opr.LastName + ', ' + opr.FirstName AS 'Name'
FROM
	[Role] r 
	LEFT JOIN User_Role ur ON ur.RoleID = 4
	LEFT JOIN Operator opr ON opr.UserID = ur.UserID
WHERE
	r.RoleID = 4 --OR r.RoleID = 2
	AND
	opr.Deleted = 0
ORDER BY 
	opr.LastName, opr.FirstName
GO
GRANT VIEW DEFINITION ON [RoleGetAdministrators] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [RoleGetAdministrators] TO [db_dml]
GO

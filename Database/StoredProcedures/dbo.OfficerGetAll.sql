/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OfficerGetAll]

	@AgencyID	INT

AS

		SELECT	o.OfficerID, 
				ISNULL(o.LastName + ', ', '') + ISNULL(o.FirstName, '') AS 'OfficerName'
		FROM	Officer o (NOLOCK)
		left JOIN [User_role] u on o.userid = u.userid 
		WHERE (o.Deleted = '0')
        and 
		
			((@AgencyID<0)
			or
			(o.AgencyID = @AgencyID))
            and
        (
            (u.RoleID <> '3')
		)
 
		
		ORDER BY o.LastName, o.FirstName

GO
GRANT EXECUTE ON [OfficerGetAll] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OfficerGetAll] TO [db_object_def_viewers]
GO

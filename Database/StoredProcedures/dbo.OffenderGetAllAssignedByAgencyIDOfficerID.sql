/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetAllAssignedByAgencyIDOfficerID]

	@AgencyID	INT,
	@OfficerID	INT,
	@RoleID		INT

AS

		SELECT o.OffenderID, 
		ISNULL(o.LastName + ', ', '') + ISNULL(o.FirstName, '') AS 'OffenderName'
		FROM	Offender o  (NOLOCK) 
		left JOIN Offender_Officer  oo (NOLOCK) ON o.OffenderID = oo.OffenderID
		LEFT JOIN TrackerAssignment ta (NOLOCK) ON o.OffenderID = ta.OffenderID 
		and ta.createdDate =
        ( select max(createddate) from  TrackerAssignment where offenderID=o.OffenderID) 
		WHERE(
				(
					(@RoleID = 2)
					AND 
					(o.AgencyID = @AgencyID)
				)
				OR	
				(
					(
						(@AgencyID=0)
						or
						(o.AgencyID = @AgencyID)
					)
					AND(
						(@OfficerID=0)
						or
						(oo.OfficerID = @OfficerID)
					)
				)
			)
				
			AND o.Deleted = 0
			AND ta.TrackerAssignmentTypeID = 1
		ORDER BY o.LastName, o.FirstName
		
	
GO
GRANT EXECUTE ON [OffenderGetAllAssignedByAgencyIDOfficerID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderGetAllAssignedByAgencyIDOfficerID] TO [db_object_def_viewers]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OfficerGetGridInfoByUserID]
	@UserID INT
AS

SELECT	o.OfficerID, o.FirstName, o.LastName, r.[Role], a.Agency
FROM Officer o
	INNER JOIN Agency a ON o.AgencyID = a.AgencyID 
	INNER JOIN User_Role ur ON o.UserID = ur.UserID
	INNER JOIN [Role] r ON ur.RoleID = r.RoleID
	INNER JOIN Distributor d ON d.DistributorID = a.DistributorID AND d.TamID = @UserID
WHERE o.Deleted = 0
ORDER BY a.Agency, r.[Role], o.LastName, o.FirstName

--FROM Distributor d
--	INNER JOIN Agency a ON a.DistributorID = d.DistributorID
--	INNER JOIN Officer o ON a.AgencyID = o.AgencyID
--	INNER JOIN User_Role ur ON o.UserID = ur.UserID
--	INNER JOIN [Role] r ON ur.RoleID = r.RoleID
--WHERE	
--		d.TamID = @UserID
--		AND
--		(
--			(@DistributorID<=0)
--			or
--			(d.DistributorID = @DistributorID )
--		)
--		AND o.Deleted = 0
--ORDER BY a.Agency, r.[Role], o.LastName, o.FirstName
GO
GRANT VIEW DEFINITION ON [OfficerGetGridInfoByUserID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OfficerGetGridInfoByUserID] TO [db_dml]
GO
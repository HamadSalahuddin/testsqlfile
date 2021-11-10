/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DistributorEmployeeGetPasscodeByDistributorId]
@DistributorID INT
AS
BEGIN
	SELECT DE.DistributorEmployeeID, RTRIM(DE.LastName) + ', ' + RTRIM(DE.FirstName) + ' (' + RTRIM(U.UserPassCode) + ')' as 'DistEmployeeAndPasscode'
	FROM DistributorEmployee DE join [User] U on DE.UserID = U.UserID
	WHERE DistributorID = @DistributorID AND DE.Deleted = 0
    order by DE.LastName
END
GO
GRANT EXECUTE ON [DistributorEmployeeGetPasscodeByDistributorId] TO [db_dml]
GO
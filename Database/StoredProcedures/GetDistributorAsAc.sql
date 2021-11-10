/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GetDistributorAsAc]
	@userID int
AS
BEGIN
	SET NOCOUNT ON;

SELECT Distributor.Assign ,Distributor.Activate
FROM         Distributor LEFT JOIN
                      DistributorEmployee ON Distributor.DistributorID = DistributorEmployee.DistributorID
WHERE (DistributorEmployee.UserID = @userID)
END
GO
GRANT VIEW DEFINITION ON [GetDistributorAsAc] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GetDistributorAsAc] TO [db_dml]
GO
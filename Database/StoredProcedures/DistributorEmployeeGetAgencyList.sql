/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DistributorEmployeeGetAgencyList]

@userId int

AS
BEGIN

SELECT a.Agency As 'Name', a.AgencyID As 'ID'
FROM 
	DistributorEmployee de
	LEFT JOIN Agency a on a.DistributorID = de.DistributorID
WHERE UserId = @userId

END
GO
GRANT EXECUTE ON [DistributorEmployeeGetAgencyList] TO [db_dml]
GO

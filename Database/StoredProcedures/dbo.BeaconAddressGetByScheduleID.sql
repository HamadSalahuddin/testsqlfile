/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [BeaconAddressGetByScheduleID]

@ScheduleID INT

AS

	SET NOCOUNT ON

	SELECT	b.BeaconName,b.Identifier,b.AddressID,           
            a.Street1,a.Street2,a.ZipCode,a.City,a.StateID,
            g.Longitude,g.Latitude
	FROM	Beacon b
	inner join ERule e ON e.BeaconID=b.ID
	inner join [Rule]r ON r.ID=e.RuleID
	inner join Address a ON a.ID = b.AddressID 	
    	inner join GPSLocation g ON g.AddressID = a.ID
	inner join schedule s on  s.ruleid =  r.id
	    WHERE  s.ID = @ScheduleID 







GO
GRANT EXECUTE ON [BeaconAddressGetByScheduleID] TO [db_dml]
GO
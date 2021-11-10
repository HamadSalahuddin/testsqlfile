/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAutoCallIncidentIDAdd]

	@IncidentID	 NVARCHAR(7)
	
AS 
    
	INSERT INTO dbo.AutoCallIncidents
	(IncidentID)
	VALUES
	(@IncidentID)

	

GO
GRANT EXECUTE ON [mAutoCallIncidentIDAdd] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRule_AgencyDelete]
	@GeoRuleID INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE GeoRule_Agency 
	WHERE GeoRuleID=@GeoRuleID
	
END
GO
GRANT VIEW DEFINITION ON [GeoRule_AgencyDelete] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GeoRule_AgencyDelete] TO [db_dml]
GO

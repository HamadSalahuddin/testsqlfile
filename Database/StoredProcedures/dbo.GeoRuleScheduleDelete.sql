/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleScheduleDelete]
	@GeoRuleScheduleID INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE GeoRuleSchedule 
	WHERE GeoRuleScheduleID=@GeoRuleScheduleID
	
END
GO
GRANT VIEW DEFINITION ON [GeoRuleScheduleDelete] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GeoRuleScheduleDelete] TO [db_dml]
GO

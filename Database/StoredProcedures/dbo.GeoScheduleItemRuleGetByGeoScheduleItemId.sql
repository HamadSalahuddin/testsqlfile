/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoScheduleItemRuleGetByGeoScheduleItemId]
	
	@GeoScheduleItemId				uniqueidentifier
	
AS

BEGIN
  
 SELECT     GeoScheduleItem.GeoScheduleItemId, GeoScheduleItem.SchedulePriority, GeoScheduleItem.LocationType, GeoScheduleItem.LocationId, 
                      GeoScheduleItem.ScheduleId, GeoscheduleItemRule.Id, GeoscheduleItemRule.RuleData
FROM         GeoScheduleItem INNER JOIN
                      GeoscheduleItemRule ON GeoScheduleItem.GeoScheduleItemId = GeoscheduleItemRule.GeoScheduleItemId

	WHERE     GeoScheduleItem.GeoScheduleItemId = @GeoScheduleItemId
end








GO
GRANT EXECUTE ON [GeoScheduleItemRuleGetByGeoScheduleItemId] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [GeoScheduleItemRuleGetByGeoScheduleItemId] TO [db_object_def_viewers]
GO
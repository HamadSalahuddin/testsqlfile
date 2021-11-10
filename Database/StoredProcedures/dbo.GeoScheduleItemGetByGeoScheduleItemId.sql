/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoScheduleItemGetByGeoScheduleItemId]
	
	@GeoScheduleItemId				uniqueidentifier
	
AS

BEGIN
  SELECT     GeoScheduleItem.GeoScheduleItemId, GeoScheduleItem.SchedulePriority, GeoScheduleItem.LocationType, GeoScheduleItem.LocationId, 
                      GeoScheduleItem.ScheduleId, GeoSchedule.Name, GeoSchedule.Description, GeoSchedule.ScheduleState, GeoSchedule.ScheduleStateTime, 
                      GeoSchedule.AssignedOffender, GeoSchedule.OwnerID
FROM         GeoScheduleItem INNER JOIN
                      GeoSchedule ON GeoScheduleItem.ScheduleId = GeoSchedule.Id

	WHERE     GeoScheduleItem.GeoScheduleItemId = @GeoScheduleItemId
end




GO
GRANT EXECUTE ON [GeoScheduleItemGetByGeoScheduleItemId] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [GeoScheduleItemGetByGeoScheduleItemId] TO [db_object_def_viewers]
GO
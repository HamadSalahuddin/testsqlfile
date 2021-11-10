/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoScheduleItemGetByScheduleId]
	
	@ScheduleId					uniqueidentifier
	
AS

BEGIN
	Select 
		GeoScheduleItem.GeoScheduleItemId,
		GeoScheduleItem.SchedulePriority,
		GeoScheduleItem.LocationType,
		GeoScheduleItem.LocationId,
		GeoScheduleItem.ScheduleId,
		GeoZone.Name as LocationName,
		GeoZone.Description as LocationDescription
	FROM GeoScheduleItem
	INNER JOIN GeoZone ON GeoScheduleItem.LocationId = GeoZone.Id

	WHERE GeoScheduleItem.ScheduleId = @ScheduleId
end










GO
GRANT EXECUTE ON [GeoScheduleItemGetByScheduleId] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [GeoScheduleItemGetByScheduleId] TO [db_object_def_viewers]
GO
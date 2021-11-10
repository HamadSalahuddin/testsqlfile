/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoScheduleItemUpdate]
	
	@ScheduleId					uniqueidentifier,
	@SchedulePriority			int,
	@LocationType				int,
	@LocationId					uniqueidentifier
AS

SET NOCOUNT ON;
BEGIN
	BEGIN TRAN
	  UPDATE  GeoScheduleItem
		SET				
		SchedulePriority = @SchedulePriority,			
		LocationType =@LocationType,		
		LocationId = @LocationId	
	   WHERE ScheduleId = @ScheduleId
	COMMIT TRAN
END










GO
GRANT EXECUTE ON [GeoScheduleItemUpdate] TO [db_dml]
GO
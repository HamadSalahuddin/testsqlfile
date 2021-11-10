/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DaylightProgressUpdateSchedule]
	@TrackerID int
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	DaylightUpdateProgress
	SET		GeoRuleScheduleUpdated = 1,
			GeoRuleScheduleUpdatedTime = GetDate()
	WHERE	TrackerID = @TrackerID
END

GO
GRANT EXECUTE ON [DaylightProgressUpdateSchedule] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmGetAlarmTypeIDFromEventTypeByEventTypeID]

	@EventTypeID	INT

AS

	SELECT	AlarmType
	FROM	Gateway.dbo.EventTypes
	WHERE	EventID = @EventTypeID





GO
GRANT EXECUTE ON [AlarmGetAlarmTypeIDFromEventTypeByEventTypeID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AlarmGetAlarmTypeIDFromEventTypeByEventTypeID] TO [db_object_def_viewers]
GO

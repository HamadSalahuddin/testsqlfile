/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [EventTypeGetAllEvents]

AS

	SELECT	EventTypeID, AbbrevEventType as EventType
	FROM	EventType 
	join Gateway.dbo.EventTypes ge on ge.Eventid= EventTypeID 
	
	WHERE	AlarmType = 1 -- 1: notification-only
	ORDER BY EventType
GO
GRANT VIEW DEFINITION ON [EventTypeGetAllEvents] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [EventTypeGetAllEvents] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAlarmProtocolEventTypeGetAll]

AS

	SELECT	AlarmProtocolEventID, GatewayEventID, AlarmName
	FROM	AlarmProtocolEvent
	ORDER BY DisplayOrder

GO
GRANT EXECUTE ON [mAlarmProtocolEventTypeGetAll] TO [db_dml]
GO

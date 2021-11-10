/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [EventTypeGetAllAlarmTypes]
	@AgencyID int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT et.EventTypeID, et.longname as EventType,et.AbbrevEventType, Isnull(ap.AlarmProtocolID,0) as AlarmProtocolID
	FROM EventType et
	LEFT JOIN AlarmProtocol ap ON et.EventTypeID = ap.EventTypeID and ap.AgencyID = @AgencyID
	join Gateway.dbo.EventTypes ge on ge.Eventid = et.EventTypeID
	WHERE ge.AlarmType != 1 
		  
END
GO
GRANT VIEW DEFINITION ON [EventTypeGetAllAlarmTypes] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [EventTypeGetAllAlarmTypes] TO [db_dml]
GO
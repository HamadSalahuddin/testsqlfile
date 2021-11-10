/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [EventGetByEventID]
	@iEventID		INT,
	@sEventDateTime BIGINT,
	@SO				INT,
	@OPR			INT,
	@OffenderID		INT

AS
BEGIN
	SET NOCOUNT ON;

SELECT
	e.DeviceID, 
	e.TrackerNumber,
	e.EventTime, 
	e.EventDateTime,
	e.EventID,
	ISNULL(e.AlarmType, 1) AS 'AlarmType', -- 1: notification
	ISNULL(e.[AlarmAssignmentStatusName],'Unassigned') AS 'AlarmAssignmentStatusName',
	et.AbbrevEventType as EventName,
	ISNULL(ROUND(e.Longitude,5), 0) AS 'Longitude',
	ISNULL(ROUND(e.Latitude,5), 0) AS 'Latitude',
	e.Address AS 'Address',
--	ISNULL(o.FirstName+' ','')+ISNULL(o.MiddleName+' ','')+ISNULL(o.LastName,'') AS 'OffenderName',
	e.OffenderName,
	e.OffenderID,
	( (SELECT COUNT (*) FROM AlarmNote WHERE AlarmID = e.AlarmID )
		+ (SELECT COUNT (*) FROM EventNote WHERE DeviceID=e.DeviceID and EventTime=e.EventTime and	EventID=e.eventid)) 
		as 'NoteCount',
	e.AlarmID,
	ISNULL(e.GpsValid,0) AS 'GpsValid',
	ISNULL(e.GpsValidSatellites,0) AS 'GpsValidSatellites',
	e.GeoRule
    
FROM 
	[fnAllEvents] () e
--	LEFT JOIN Offender o ON o.OffenderID = e.OffenderID
	LEFT JOIN EventType et ON et.EventtypeID= e.EventID
WHERE
	EventID = @iEventID
	and e.OffenderID = @OffenderID
	AND EVENTTIME = @sEventDateTime
	AND ((@SO<0) OR (e.SO=@SO))
	AND ((@OPR<0) OR (e.OPR=@OPR))
	AND e.OffenderDeleted = 0

END



GO
GRANT VIEW DEFINITION ON [EventGetByEventID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [EventGetByEventID] TO [db_dml]
GO

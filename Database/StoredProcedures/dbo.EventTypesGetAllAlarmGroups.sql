/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [EventTypesGetAllAlarmGroups]
	@SO				INT,
	@OPR			INT
AS

	SELECT	'G' + Convert(varchar ,e.EventTypeGroupID) as EventID,
			e.EventTypeGroupName as  EventName
	FROM	EventType et
	join    EventTypeGroup e on et.eventtypegroupid = e.eventtypegroupid
	join	Gateway.dbo.EventTypes ge on ge.eventid = et.eventtypeid	
	WHERE	VISIBLE=1 AND ge.AlarmType > 1 
		and
			(
				(@SO<0)
				or
				 (et.SO=@SO)
			)
		and (
				(@OPR<0)
				or
				(et.OPR=@OPR)
			)
	group by e.EventTypeGroupID ,e.EventTypeGroupName 
GO
GRANT VIEW DEFINITION ON [EventTypesGetAllAlarmGroups] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [EventTypesGetAllAlarmGroups] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [EventTypesGetAllAlarms]
	@SO				INT,
	@OPR			INT
AS

	SELECT	Convert(varchar,EventTypeID) as EventID,AbbrevEventType as  EventName
	FROM	EventType e
	inner join gateway.dbo.eventtypes ge on ge.Eventid= e.Eventtypeid
	WHERE VISIBLE=1 AND	ge.AlarmType > 1 
			and (
				(@SO<0)
				or
				 (e.SO=@SO)
			)
		and (
				(@OPR<0)
				or
				(e.OPR=@OPR)
			)
	ORDER BY e.AbbrevEventType
GO
GRANT EXECUTE ON [EventTypesGetAllAlarms] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [EventTypesGetAllAlarms] TO [db_object_def_viewers]
GO

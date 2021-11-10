/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StaticGetEventTypeForEvent] 
	@EventTypeID bigint

AS

Select * from EventType as et
LEFT OUTER JOIN Gateway.dbo.EventTypes as ge ON ge.EventID=et.EventTypeID 
WHERE et.EventTypeID=@EventTypeID


GO
GRANT EXECUTE ON [StaticGetEventTypeForEvent] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [StaticGetEventTypeForEvent] TO [db_object_def_viewers]
GO

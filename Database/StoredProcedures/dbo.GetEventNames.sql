/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GetEventNames]

AS
BEGIN
SELECT 
EventTypeID
,AbbrevEventType
From EventType
Where Bringover = 1

END
GO
GRANT EXECUTE ON [GetEventNames] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ScheduleGetByOffenderID]  
 @OffenderID int  
   
  
AS  
 select id
from GeoSchedule   
 where AssignedOffender = @OffenderID  


GO
GRANT VIEW DEFINITION ON [ScheduleGetByOffenderID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [ScheduleGetByOffenderID] TO [db_dml]
GO

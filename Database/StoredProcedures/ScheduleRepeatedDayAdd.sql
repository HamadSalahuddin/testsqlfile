/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ScheduleRepeatedDayAdd]
	@ScheduleID		     INT,	
	@DayID               INT	
	

AS
BEGIN

	INSERT INTO dbo.ScheduleRepeatedDay
	(ScheduleID,DayID)
	VALUES
	(@ScheduleID,@DayID)


END





GO
GRANT EXECUTE ON [ScheduleRepeatedDayAdd] TO [db_dml]
GO

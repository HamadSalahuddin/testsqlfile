/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAlarmTypeProtocolActionPriorityAll]

	

AS
	 select g.AlarmProtocolActionPriorityID, g.AlarmProtocolActionPriority, g.RoleID  
 from AlarmProtocolActionPriority  g 
GO
GRANT EXECUTE ON [mAlarmTypeProtocolActionPriorityAll] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mProtocolActionTypesAll]


AS
	select g.AlarmProtocolActionTypeID, g.AlarmProtocolActionType, g.RoleID
			
	from AlarmProtocolActionType  g 
GO
GRANT EXECUTE ON [mProtocolActionTypesAll] TO [db_dml]
GO
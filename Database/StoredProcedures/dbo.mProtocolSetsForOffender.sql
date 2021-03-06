/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mProtocolSetsForOffender]
	@OffenderID int

AS
	select g.Offender_AlarmProtocolSetID, g.AlarmProtocolSetID, g.CreatedByID, g.CreatedDate, g.Deleted
			
	from Offender_AlarmProtocolSet  g 
GO
GRANT EXECUTE ON [mProtocolSetsForOffender] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mOffenderProtocolsAll]

	

AS
	select g.Offender_AlarmProtocolSetID, g.OffenderID, g.AlarmProtocolSetID, g.CreatedByID
	from Offender_AlarmProtocolSet  g 
   Where g.deleted = 0
GO
GRANT EXECUTE ON [mOffenderProtocolsAll] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mEventTypesAll]

	

AS
	select EventTypeID,AbbrevEventType,EventTypeGroupID,SO,OPR,EventDescription,
		BringOver,LongName,Visible
	from EventType
GO
GRANT EXECUTE ON [mEventTypesAll] TO [db_dml]
GO
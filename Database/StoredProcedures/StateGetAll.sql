/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StateGetAll]

AS

	SELECT	State as 'Name', StateID as 'ID'
	FROM	State



	
	
GO
GRANT EXECUTE ON [StateGetAll] TO [db_dml]
GO

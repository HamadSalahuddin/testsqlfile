/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ERuleGetAll]

AS

	SET NOCOUNT ON

	SELECT	ID,[Name] as 'ERuleName',BeaconID,AssignedETrackerID,RuleID
	FROM	dbo.ERule
	




GO
GRANT EXECUTE ON [ERuleGetAll] TO [db_dml]
GO

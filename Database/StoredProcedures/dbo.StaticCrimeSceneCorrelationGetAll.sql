/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StaticCrimeSceneCorrelationGetAll]
AS
BEGIN
	
	SELECT * FROM CrimeSceneCorrelation
END
GO
GRANT VIEW DEFINITION ON [StaticCrimeSceneCorrelationGetAll] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [StaticCrimeSceneCorrelationGetAll] TO [db_dml]
GO

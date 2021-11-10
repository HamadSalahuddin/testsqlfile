/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StaticCrimeLocationGetAll]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT CrimeSceneId,ID,Street,City,StateID,Zip,Latitude,Longitude,CreatedByID FROM CrimeSceneLocation
END
GO
GRANT EXECUTE ON [StaticCrimeLocationGetAll] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [StaticCrimeLocationGetAll] TO [db_object_def_viewers]
GO
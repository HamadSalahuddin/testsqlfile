/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [CrimeSceneLocationDelete]
	@crimeSceneID int
	
AS
BEGIN
	SET NOCOUNT ON;
    DELETE FROM [dbo].[CrimeSceneLocation]  WHERE CrimeSceneID = @crimeSceneID
END
GO
GRANT VIEW DEFINITION ON [CrimeSceneLocationDelete] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [CrimeSceneLocationDelete] TO [db_dml]
GO

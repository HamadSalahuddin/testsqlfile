/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [CrimeSceneCorrelationDelete]
	@crimeSceneID int
	
AS
BEGIN
	SET NOCOUNT ON;
    DELETE FROM [dbo].[CrimeSceneCorrelation]  WHERE CrimeSceneID = @crimeSceneID
END
GO
GRANT EXECUTE ON [CrimeSceneCorrelationDelete] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [CrimeSceneCorrelationDelete] TO [db_object_def_viewers]
GO

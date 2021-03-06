/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [CrimeSceneAdd]
@ID				INT OUTPUT,
@DateTime			datetime,
@CaseNumber			nvarchar(50),
@Notes				nvarchar(50) = null,
@CreatedByID		int
	
AS
INSERT INTO CrimeScene
([DateTime],CaseNumber,Notes,CreatedByID)
VALUES
(@DateTime,@CaseNumber,@Notes,@CreatedByID)
SET @ID	 = @@IDENTITY
GO
GRANT EXECUTE ON [CrimeSceneAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [CrimeSceneAdd] TO [db_object_def_viewers]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [CrimeSceneCorrelationAdd] 
@ID				INT OUTPUT,
@CrimeSceneID	INT,
@TimeBefore		datetime,
@TimeAfter		datetime,
@Proximity		float,
@CreatorID		INT,
@Completed		bit,
@IsMile			bit
	
AS
INSERT INTO CrimeSceneCorrelation
(CrimeSceneID,TimeBefore,TimeAfter,Proximity,CreatorID,Completed,IsMile)
VALUES
(@CrimeSceneID,@TimeBefore,@TimeAfter,@Proximity,@CreatorID,@Completed,@IsMile)
SET @ID	 = @@IDENTITY
GO
GRANT VIEW DEFINITION ON [CrimeSceneCorrelationAdd] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [CrimeSceneCorrelationAdd] TO [db_dml]
GO

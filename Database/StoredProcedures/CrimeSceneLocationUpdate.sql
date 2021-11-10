/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [CrimeSceneLocationUpdate]
@ID				INT,
@CrimeSceneId	INT,
@Street	nvarchar(50),
@City	nvarchar(50)	,
@StateID		INT,
@Zip		nvarchar(25),
@Latitude	float,	
@Longitude	float,
@CreatedByID	INT
AS
UPDATE [TrackerPal].[dbo].[CrimeSceneLocation]

   SET [CrimeSceneId] =	@CrimeSceneId
    ,[Street] =		@Street
    ,[City] =		@City	
    ,[StateID] =	@StateID		
    ,[Zip] =		@Zip
    ,[Latitude]=	@Latitude
	,[Longitude]=	@Longitude
	,[CreatedByID]= @CreatedByID

 WHERE ID = @ID 
 
GO
GRANT VIEW DEFINITION ON [CrimeSceneLocationUpdate] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [CrimeSceneLocationUpdate] TO [db_dml]
GO
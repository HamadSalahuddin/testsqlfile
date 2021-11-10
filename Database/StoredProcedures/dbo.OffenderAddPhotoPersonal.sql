/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderAddPhotoPersonal]
	@iOffenderImageID int OUTPUT,
	@iOffenderID int,
	@sFileName nvarchar(50),
	@sFilePath nvarchar(150)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO OffenderImage
	(OffenderID, ImageType, ImageName, ImagePath)
	VALUES
	(@iOffenderID, 1, @sFileName, @sFilePath)

	SET @iOffenderImageID = @@IDENTITY
END


GO
GRANT VIEW DEFINITION ON [OffenderAddPhotoPersonal] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderAddPhotoPersonal] TO [db_dml]
GO

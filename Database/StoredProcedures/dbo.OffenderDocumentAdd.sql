/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderDocumentAdd]
	@iOffenderDocumentID int OUTPUT,
	@iOffenderID int,
	@sDocumentName nvarchar(max),
	@sDocumentPath nvarchar(max),
	@fDocumentSize float,
	@sDocumentType nvarchar(50),
	@dtDocumentDate datetime

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO OffenderDocument
	(OffenderID, DocumentName, DocumentPath, FileSize, FileType, FileDate)
	VALUES
	(@iOffenderID, @sDocumentName, @sDocumentPath, @fDocumentSize, @sDocumentType, @dtDocumentDate)

	SET @iOffenderDocumentID = @@IDENTITY
END


GO
GRANT EXECUTE ON [OffenderDocumentAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderDocumentAdd] TO [db_object_def_viewers]
GO

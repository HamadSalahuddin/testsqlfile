/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderOperatorNoteAdd]

	@OffenderOperatorNoteID	INT OUTPUT,
	@OffenderID		INT,
	@Note			NVARCHAR(2000),
	@CreatedByID	INT


AS

	INSERT INTO OffenderOperatorNote
	(OffenderID, Note, CreatedByID)
	VALUES
	(@OffenderID, @Note, @CreatedByID)

	SET @OffenderOperatorNoteID = @@IDENTITY
GO
GRANT EXECUTE ON [OffenderOperatorNoteAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderOperatorNoteAdd] TO [db_object_def_viewers]
GO

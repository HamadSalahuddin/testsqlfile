/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAlarmNoteInsert]

	@AlarmNoteID	INT OUTPUT,
	@AlarmID		INT,
	@Note			NVARCHAR(2000),
	@CreatedByID	INT

AS

	INSERT INTO AlarmNote
	(AlarmID, Note, CreatedByID)
	VALUES
	(@AlarmID, @Note, @CreatedByID)

	SET @AlarmNoteID = @@IDENTITY
GO
GRANT EXECUTE ON [mAlarmNoteInsert] TO [db_dml]
GO
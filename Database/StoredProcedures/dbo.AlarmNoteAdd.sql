/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmNoteAdd]

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

	if ((select count(*) from rprtAlarmMonitorCenterSubGrid WHERE ParentAlarmID=@AlarmID AND AlarmID <> @AlarmID) > 0)
	BEGIN
		--insert new records for all subalarms for this alarm
		INSERT INTO AlarmNote(
			AlarmID,
			Note,
			CreatedByID)
		SELECT
			 SubAlarms.AlarmID,
			 @Note,
			 @CreatedByID
		FROM rprtAlarmMonitorCenterSubGrid AS SubAlarms
		WHERE SubAlarms.ParentAlarmID=@AlarmID AND SubAlarms.AlarmID <> @AlarmID
	END
GO
GRANT EXECUTE ON [AlarmNoteAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AlarmNoteAdd] TO [db_object_def_viewers]
GO

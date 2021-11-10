/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [Offender_AlarmProtocolSetUpdate]

	@OffenderID	INT,
	@ModifiedByID INT

AS

	UPDATE	Offender_AlarmProtocolSet
	SET		Deleted = 1,
			ModifiedByID = @ModifiedByID,
			ModifiedDate = GETUTCDATE()
	WHERE	OffenderID = @OffenderID AND
			Deleted = 0
GO
GRANT EXECUTE ON [Offender_AlarmProtocolSetUpdate] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [Offender_AlarmProtocolSetUpdate] TO [db_object_def_viewers]
GO

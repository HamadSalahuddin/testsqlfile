/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmProtocolSetUpdate]

	@AlarmProtocolSetID		INT,
	@AlarmProtocolSetName	NVARCHAR(50),
	@ModifiedByID			INT

AS

	UPDATE	AlarmProtocolSet
	SET		AlarmProtocolSetName = @AlarmProtocolSetName,
			ModifiedByID = @ModifiedByID,
			ModifiedDate = GETUTCDATE()
	WHERE	AlarmProtocolSetID = @AlarmProtocolSetID
GO
GRANT VIEW DEFINITION ON [AlarmProtocolSetUpdate] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [AlarmProtocolSetUpdate] TO [db_dml]
GO

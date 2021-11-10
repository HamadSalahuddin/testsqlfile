/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmProtocolSetDelete]
	@AlarmProtocolSetID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE
	FROM    dbo.AlarmProtocolAction
	WHERE   AlarmProtocolSetID = @AlarmProtocolSetID
	
	DELETE
	FROM    dbo.AlarmProtocolSet
	WHERE   AlarmProtocolSetID = @AlarmProtocolSetID
END


GO
GRANT VIEW DEFINITION ON [AlarmProtocolSetDelete] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [AlarmProtocolSetDelete] TO [db_dml]
GO
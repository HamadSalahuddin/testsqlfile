/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DaylightProgressUpdateActionInstance]
	@TrackerID int,
	@ActionInstanceID bigint
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	DaylightUpdateProgress
	SET		ActionInstanceID = @ActionInstanceID,
			ActionInstanceIDTime = GetDate()
	WHERE	TrackerID = @TrackerID
END

GO
GRANT EXECUTE ON [DaylightProgressUpdateActionInstance] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerRmaReasonGet] 
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		*
	FROM 
		TrackerRmaReason
	
END
GO
GRANT VIEW DEFINITION ON [TrackerRmaReasonGet] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [TrackerRmaReasonGet] TO [db_dml]
GO

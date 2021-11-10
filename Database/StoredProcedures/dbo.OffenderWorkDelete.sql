/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderWorkDelete]
	@iOffenderWorkID int

AS
BEGIN

	DELETE FROM OffenderWork 
	WHERE OffenderWorkID = @iOffenderWorkID 
END
GO
GRANT VIEW DEFINITION ON [OffenderWorkDelete] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderWorkDelete] TO [db_dml]
GO

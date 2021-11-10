/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ContactTypeGetAll]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ContactTypeID, ContactTypeDescription
	FROM ContactType
END

GO
GRANT VIEW DEFINITION ON [ContactTypeGetAll] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [ContactTypeGetAll] TO [db_dml]
GO

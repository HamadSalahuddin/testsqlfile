/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReligionGetAllReligions]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Religion
END

GO
GRANT EXECUTE ON [ReligionGetAllReligions] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReligionGetAllReligions] TO [db_object_def_viewers]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [CountryGetByID]

	@Country	NVARCHAR(50) OUTPUT,
	@CountryID	INT

AS

	SELECT	@Country = Country
	FROM	Country
	WHERE	CountryID = @CountryID
GO
GRANT EXECUTE ON [CountryGetByID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [CountryGetByID] TO [db_object_def_viewers]
GO
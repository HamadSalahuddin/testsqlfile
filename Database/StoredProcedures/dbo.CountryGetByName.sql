/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [CountryGetByName]

	@Country	NVARCHAR(50) 
AS

	SELECT	TOP(1) *
	FROM	Country
	WHERE	Country = @Country
GO
GRANT EXECUTE ON [CountryGetByName] TO [db_dml]
GO

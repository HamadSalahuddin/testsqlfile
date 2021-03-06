/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [EthnicityGetAllEthnicities]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Ethnicity
END

GO
GRANT EXECUTE ON [EthnicityGetAllEthnicities] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [EthnicityGetAllEthnicities] TO [db_object_def_viewers]
GO

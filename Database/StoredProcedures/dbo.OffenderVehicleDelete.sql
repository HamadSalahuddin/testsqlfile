/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderVehicleDelete]
	@iOffenderVehicleID int

AS
BEGIN

	DELETE FROM OffenderVehicle 
	WHERE OffenderVehicleID = @iOffenderVehicleID 
END
GO
GRANT EXECUTE ON [OffenderVehicleDelete] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderVehicleDelete] TO [db_object_def_viewers]
GO

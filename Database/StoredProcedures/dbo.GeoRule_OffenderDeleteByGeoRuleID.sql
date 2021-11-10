/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRule_OffenderDeleteByGeoRuleID]

	@GeoRuleID	INT

AS
UPDATE GEORULE SET STATUSID=2 WHERE GEORULEID = @GeoRuleID

	DELETE FROM GeoRule_Offender
	WHERE GeoRuleID = @GeoRuleID
GO
GRANT EXECUTE ON [GeoRule_OffenderDeleteByGeoRuleID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [GeoRule_OffenderDeleteByGeoRuleID] TO [db_object_def_viewers]
GO

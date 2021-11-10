/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRule_OffenderDeleteAllByOffenderID]

	@OffenderID	INT

AS

UPDATE GEORULE 
SET STATUSID = 2, UpdateInProgress = 0, FileID = 0
WHERE GEORULEID IN (SELECT GEORULEID FROM GeoRule_Offender WHERE OffenderID = @OffenderID)	

DELETE FROM GeoRule_Offender
WHERE OffenderID = @OffenderID
GO
GRANT VIEW DEFINITION ON [GeoRule_OffenderDeleteAllByOffenderID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GeoRule_OffenderDeleteAllByOffenderID] TO [db_dml]
GO

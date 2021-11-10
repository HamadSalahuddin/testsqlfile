/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleUpdateFileID]

	@GeoRuleID					INT,
	@FileID						INT

AS

	UPDATE	GeoRule
	SET		FileID = @FileID,
			UpdateInProgress = 1
	WHERE	GeoRuleID = @GeoRuleID
GO
GRANT EXECUTE ON [GeoRuleUpdateFileID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [GeoRuleUpdateFileID] TO [db_object_def_viewers]
GO

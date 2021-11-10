/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRule_OffenderAdd]

	@GeoRuleID	INT,
	@OffenderID	INT
--	@ZoneID INT

AS
    Declare @Zoneid smallint
    SET @ZoneID = (Select 
    ISNULL(max(ZoneID)+1,1) from Georule_Offender Where Offenderid = @Offenderid)
    
	INSERT INTO GeoRule_Offender
	(GeoRuleID, OffenderID, ZoneID)
	VALUES
	(@GeoRuleID, @OffenderID, @ZoneID)

	UPDATE GEORULE SET STATUSID=3 WHERE GEORULEID =@GeoRuleID

GO
GRANT VIEW DEFINITION ON [GeoRule_OffenderAdd] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GeoRule_OffenderAdd] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mGeoRuleGetByOffenderIDZoneID]

	@OffenderID		INT,
	@ZoneID			BIGINT,
	@GeoruleID      INT OUTPUT
AS
BEGIN
	
	SELECT	@GeoruleID = g.GeoruleID			
	FROM    GeoRule_Offender g	
	WHERE   g.OffenderID = @OffenderID
            and g.Zoneid = @ZoneID	
END

GO
GRANT EXECUTE ON [mGeoRuleGetByOffenderIDZoneID] TO [db_dml]
GO

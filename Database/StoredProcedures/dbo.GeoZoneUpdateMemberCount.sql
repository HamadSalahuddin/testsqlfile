/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoZoneUpdateMemberCount]

         @ZoneGroupId   uniqueidentifier,
		 @MemberType    Int

AS
SET NOCOUNT ON;
BEGIN
	DECLARE @memberCount int;
	
	SET @memberCount = (SELECT COUNT(*) FROM GeoZoneGroupMembers WHERE ZoneGroupId = @ZoneGroupId AND MemberType = @MemberType);
			
	IF (@MemberType = 1) --MemberType of 1 is a Group
	BEGIN
		UPDATE GeoZone SET GroupChildCount = @memberCount
		WHERE Id = @ZoneGroupId
	END
	ELSE
	BEGIN --MemberType of 2 is a Zone
		UPDATE GeoZone SET ZoneChildCount = @memberCount
		WHERE Id = @ZoneGroupId
	END
END



GO
GRANT EXECUTE ON [GeoZoneUpdateMemberCount] TO [db_dml]
GO
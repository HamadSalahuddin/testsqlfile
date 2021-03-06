/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
-- =============================================
-- Author:		Keith Griffiths
-- Create date: Oct 16, 2009
-- Description:	update/insert Geo_Agency to reflect whether a geozone belongs to the library or not
-- =============================================
CREATE PROCEDURE [GeoRuleLibrarySave]
	@GeoruleID int,
	@AgencyID int
AS
BEGIN
	SET NOCOUNT ON

	UPDATE [Trackerpal].[dbo].[GeoRule_Agency]
	SET [GeoRuleID] = @GeoruleID
	,[AgencyID] = @AgencyID
	,[Library_Item] = 1
	WHERE ((GeoRuleID=@GeoruleID) AND (AgencyID=@AgencyID))

	--if not an update then it must be an insert
	IF @@ROWCOUNT = 0
		INSERT INTO [Trackerpal].[dbo].[GeoRule_Agency]
		([GeoRuleID]
		,[AgencyID]
		,[Library_Item])
		VALUES
		(@GeoruleID
		,@AgencyID
		,1)
END

GO
GRANT EXECUTE ON [GeoRuleLibrarySave] TO [db_dml]
GO

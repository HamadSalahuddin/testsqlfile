USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleGeoZoneAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleGeoZoneAdd]
GO

USE TrackerPal
GO

-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 07-Dec-2009
-- Description:	This procedure adds a geozone for library geo rule. 
-- =============================================
CREATE PROCEDURE GeoRuleGeoZoneAdd
	
	@GeoRuleGeoZoneID  int OUTPUT, 
	@GeoRuleReferencePointID int,
    @GeoRuleShapeID int,  
    @Longitude float, @Latitude float, 
	@Longitudes varchar(5000), @Latitudes varchar(5000), 
	@Radius int,
	@Width float, @Height float, 
	@Rotation int
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO GeoRuleGeoZone(GeoRuleReferencePointID,
				GeoRuleShapeID,  Longitude, Latitude, Longitudes, 
				Latitudes, 
				Radius,Width, Height, 
				Rotation)

	VALUES(@GeoRuleReferencePointID,
    @GeoRuleShapeID, @Longitude, @Latitude, 
	@Longitudes, @Latitudes, 
	@Radius, @Width, @Height, 
	@Rotation)

SET @GeoRuleGeoZoneID = @@IDENTITY
END
GO
--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleGeoZoneAdd] TO db_dml;
GO
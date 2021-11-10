USE [Trackerpal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SA_GeoRuleGetLibrary]
AS
SELECT     lib.GeoRuleLibraryItemName, lib.RuleTypeID, zone.GeoRuleShapeID, zone.Longitude, zone.Latitude, zone.Longitudes, zone.Latitudes, zone.Radius, 
                      zone.Width, zone.Height, zone.Rotation, rp.Street, rp.City, rp.StateID, rp.PostalCode, rp.CountryID, rp.Longitude AS Expr1, rp.Latitude AS Expr2, 
                      s.AlwaysOn, s.StartTime, s.EndTime, s.Sunday, s.Monday, s.Tuesday, s.Wednesday, s.Thursday, s.Friday, s.Saturday, lib.AgencyID, lib.CreatedDate, 
                      lib.CreatedByID, lib.ModifiedDate, lib.ModifiedByID, lib.GeoRuleLibraryItemID, lib.GeoRuleGeoZoneID AS Expr5, lib.GeoRuleScheduleID, 
                      zone.GeoRuleReferencePointID
FROM         dbo.GeoRuleGeoZone AS zone INNER JOIN
                      dbo.GeoRuleLibrary AS lib ON zone.GeoRuleGeoZoneID = lib.GeoRuleGeoZoneID INNER JOIN
                      dbo.GeoRuleReferencePoint AS rp ON zone.GeoRuleReferencePointID = rp.GeoRuleReferencePointID INNER JOIN
                      dbo.GeoRuleSchedule AS s ON lib.GeoRuleScheduleID = s.GeoRuleScheduleID
WHERE     (lib.GeoRuleScheduleID = lib.GeoRuleScheduleID) AND (zone.GeoRuleReferencePointID = zone.GeoRuleReferencePointID)

GO



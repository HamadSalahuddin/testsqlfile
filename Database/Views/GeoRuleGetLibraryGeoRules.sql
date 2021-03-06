
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER View [dbo].[GeoRuleGetLibraryRules]
         AS
SELECT ROW_NUMBER() OVER (ORDER BY lib.GeoRuleLibraryItemName) AS GeoRuleID,
                lib.GeoRuleLibraryItemName AS GeoRuleName,
				lib.GeoRuleLibraryItemID AS AreaID,	
                zone.GeoRuleShapeID, 
                lib.RuleTypeID As GeoRuleTypeID, 
                zone.Longitude,
                zone.Latitude,
                zone.Longitudes, 
                zone.Latitudes, 
                zone.Radius, 
                zone.Width, 
                zone.Height, 
                zone.Rotation, 
                rp.Street, 
                rp.City, 
                rp.StateID, 
                rp.PostalCode, 
                rp.CountryID, 
                rp.Longitude AS RefLongitude,
                rp.Latitude AS RefLatitude,
                s.GeoRuleScheduleID,
                s.AlwaysOn, 
                s.StartTime, 
                s.EndTime,
                s.Sunday,
                s.Monday,
                s.Tuesday, 
                s.Wednesday,    
                s.Thursday, 
                s.Friday, 
                s.Saturday, 
                lib.AgencyID, 
                lib.CreatedDate, 
                lib.CreatedByID, 
                lib.ModifiedDate,
                lib.ModifiedByID, 
                lib.GeoRuleLibraryItemID, 
                lib.GeoRuleGeoZoneID AS GeoRuleGeoZoneID, 
                lib.GeoRuleScheduleID AS Expr1, 
                zone.GeoRuleReferencePointID
            FROM dbo.GeoRuleGeoZone AS zone 
              INNER JOIN dbo.GeoRuleLibrary AS lib ON zone.GeoRuleGeoZoneID = lib.GeoRuleGeoZoneID 
              INNER JOIN dbo.GeoRuleReferencePoint AS rp ON zone.GeoRuleReferencePointID = rp.GeoRuleReferencePointID 
              INNER JOIN dbo.GeoRuleSchedule AS s ON lib.GeoRuleScheduleID = s.GeoRuleScheduleID                        
            WHERE (lib.GeoRuleScheduleID = lib.GeoRuleScheduleID) 
              AND (zone.GeoRuleReferencePointID = zone.GeoRuleReferencePointID)
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:21:39 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: VIEW
*/
CREATE VIEW [dbo].[GeoRuleGetLibraryRules]
/*

Log
Updated by: David Riding	12/12/14		Needed to add some place holder columns due to changes for Heal and Grace.
*/
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
                zone.GeoRuleReferencePointID,
				NULL as GraceID,
				NULL as GraceEarly,
				NULL AS GraceLate,
				NULL AS Deleted
            FROM dbo.GeoRuleGeoZone AS zone 
              INNER JOIN dbo.GeoRuleLibrary AS lib ON zone.GeoRuleGeoZoneID = lib.GeoRuleGeoZoneID 
              INNER JOIN dbo.GeoRuleReferencePoint AS rp ON zone.GeoRuleReferencePointID = rp.GeoRuleReferencePointID 
              INNER JOIN dbo.GeoRuleSchedule AS s ON lib.GeoRuleScheduleID = s.GeoRuleScheduleID                        
            WHERE (lib.GeoRuleScheduleID = lib.GeoRuleScheduleID) 
              AND (zone.GeoRuleReferencePointID = zone.GeoRuleReferencePointID)


       
GO

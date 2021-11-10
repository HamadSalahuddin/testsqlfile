USE [Trackerpal]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[GeoRule_GetLibrary]
AS
SELECT GeoRule.GeoRuleID, 
       GeoRule.GeoRuleName, 
       GeoRule.GeoRuleShapeID, 
       GeoRule.GeoRuleTypeID, 
       GeoRule.GeoRuleReferencePointID, 
       GeoRule.GeoRuleScheduleID, 
       GeoRule.Longitude, 
       GeoRule.Latitude, 
       GeoRule.Radius, 
       GeoRule.Width, 
       GeoRule.Height, 
       GeoRule.Rotation, 
       GeoRule.Longitudes, 
       GeoRule.Latitudes, 
       GeoRule.AlarmInstructions, 
       GeoRule.CreatedDate, 
       GeoRule.CreatedByID, 
       GeoRule.ModifiedDate, 
       GeoRule.ModifiedByID, 
       GeoRule.Deleted, 
       GeoRule.StatusID, 
       GeoRule.FileID, 
       GeoRule.UpdateInProgress, 
       GeoRuleSchedule.GeoRuleScheduleID AS Expr1, 
       GeoRuleSchedule.AlwaysOn, 
       GeoRuleSchedule.StartTime, 
       GeoRuleSchedule.EndTime, 
       GeoRuleSchedule.Sunday, 
       GeoRuleSchedule.Monday, 
       GeoRuleSchedule.Tuesday, 
       GeoRuleSchedule.Wednesday, 
       GeoRuleSchedule.Thursday, 
       GeoRuleSchedule.Friday, 
       GeoRuleSchedule.Saturday, 
       GeoRuleReferencePoint.Street, 
       GeoRuleReferencePoint.City,
       GeoRuleReferencePoint.StateID,
       GeoRuleReferencePoint.PostalCode, 
       GeoRuleReferencePoint.CountryID,
       GeoRuleReferencePoint.Latitude AS RefLatitude, 
       GeoRuleReferencePoint.Longitude AS RefLongitude, 
       0 AS ZoneID, 
       GeoRule_Agency.AgencyID
FROM dbo.GeoRule WITH (NOLOCK) 
  INNER JOIN dbo.GeoRule_Agency ON GeoRule.GeoRuleID = GeoRule_Agency.GeoRuleID 
  LEFT OUTER JOIN dbo.GeoRuleSchedule ON GeoRule.GeoRuleScheduleID = GeoRuleSchedule.GeoRuleScheduleID 
  LEFT OUTER JOIN dbo.GeoRuleReferencePoint ON GeoRule.GeoRuleReferencePointID = GeoRuleReferencePoint.GeoRuleReferencePointID
WHERE (GeoRule.Deleted = 0) 
  AND (GeoRule_Agency.LibraryItem = 1)

GO



USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[GeoRuleGetAllByOffenderID]    Script Date: 03/20/2018 08:12:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GeoRuleGetAllByOffenderID] (
	@offenderid	INT
)
AS
	SELECT GeoRule.GeoRuleID, 
	       GeoRule.GeoRuleName, 
	       GeoRule.GeoRuleShapeID, 
	       GeoRule.GeoRuleTypeID,
	       GeoRule.StatusID,
			   ROUND(GeoRule.Longitude, 5) AS 'Longitude',  
			   ROUND(GeoRule.Latitude, 5) AS 'Latitude',    
			   GeoRule.Radius, 
			   GeoRule.Width, 
			   GeoRule.Height, 
			   GeoRule.Longitudes,
			   GeoRule.Latitudes,
			   Schedule.AlwaysOn, 
			   Schedule.StartTime, 
			   Schedule.EndTime, 
			   Schedule.Sunday, 
			   Schedule.Monday, 
			   Schedule.Tuesday,
			   Schedule.Wednesday, 
			   Schedule.Thursday, 
			   Schedule.Friday, 
			   Schedule.Saturday, 
			   GeoRule.AlarmInstructions,
			   RefPoint.Street, 
			   RefPoint.City, 
			   [State].Abbreviation,
			   RefPoint.PostalCode,
			   Country.Country,
			   GeoRule_Offender.ZoneID,
			   GeoRule_Offender.AreaID
	FROM GeoRule WITH (NOLOCK)
	  INNER JOIN GeoRule_Offender ON GeoRule.GeoRuleID = GeoRule_Offender.GeoRuleID
	  LEFT OUTER JOIN GeoRuleSchedule Schedule ON GeoRule.GeoRuleScheduleID = Schedule.GeoRuleScheduleID
	  LEFT OUTER JOIN GeoRuleReferencePoint RefPoint ON GeoRule.GeoRuleReferencePointID = RefPoint.GeoRuleReferencePointID
	  LEFT OUTER JOIN [State] ON [State].StateID = RefPoint.StateID
	  LEFT OUTER JOIN Country ON Country.CountryID = RefPoint.CountryID 
	WHERE	GeoRule_Offender.OffenderID = @OffenderID
	  AND GeoRule.StatusID <> 2                     -- // REMEMBER to uncomment this, we don't want to start uploading InActive GeoRules.
	ORDER BY GeoRule.GeoRuleName

USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetGeoRules]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetGeoRules]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetGeoRules.sql
 * Created On: 12/29/2010         
 * Created By: R.Cole  
 * Task #:     SA_1766
 * Purpose:    Returns all GeoRules for an offender regardless
 *             of GeoRule Status               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetGeoRules] (
	@OffenderID	INT
)
AS
BEGIN	
	SET NOCOUNT ON;
  SELECT GeoRule.GeoRuleID, 
	       sch.GeoRuleScheduleID,
	       rp.GeoRuleReferencePointId,
	       [state].Abbreviation,
	       rp.PostalCode,
         Country.Country,
         GeoRule_Offender.ZoneID
  FROM GeoRule WITH (NOLOCK)
    INNER JOIN GeoRule_Offender (NOLOCK) ON GeoRule.GeoRuleID = GeoRule_Offender.GeoRuleID
    LEFT JOIN GeoRuleSchedule (NOLOCK) sch ON GeoRule.GeoRuleScheduleID = sch.GeoRuleScheduleID
    LEFT JOIN GeoRuleReferencePoint (NOLOCK) rp on GeoRule.GeoRuleReferencePointId = rp.GeoRuleReferencePointId
    LEFT JOIN dbo.[State] (NOLOCK) on [state].stateID = rp.StateID
    LEFT JOIN Country (NOLOCK) on Country.CountryID = rp.CountryID 
  WHERE GeoRule_Offender.OffenderID = @OffenderID 
--    AND (GeoRule.UpdateInProgress = 1 OR GeoRule.StatusID = 3)
  ORDER BY GeoRule.GeoRuleName
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetGeoRules] TO db_dml;
GO
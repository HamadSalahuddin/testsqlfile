USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[mGeoRuleGetByOffenderID]    Script Date: 3/19/2018 11:35:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date:02-Dec-2010
-- Description:	We want to get GeoRules by OffenderID.
-- Modified By: SABBASI; #12172 - Comment #20. 
-- =============================================
ALTER  PROCEDURE  [dbo].[mGeoRuleGetByOffenderIDGeoRuleID] (
	@OffenderID INT,
	@GeoRuleID  INT
)
AS
BEGIN

	SELECt GOCoomonArea.GeoRuleID FROM GeoRule_Offender ruleoffender
	INNER JOIN GeoRule_Offender GOCoomonArea ON GOCoomonArea.AreaID = ruleoffender.AreaID AND GOCoomonArea.OffenderID = ruleoffender.OffenderID
	WHERE ruleoffender.OffenderID = @OffenderID AND ruleoffender.GeoRuleID = @GeoRuleID
 	
END


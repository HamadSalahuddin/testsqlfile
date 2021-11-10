USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_GRl_GetAllByOffenderID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_GRl_GetAllByOffenderID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 10-Jun-2010
-- Description:	We need IDs of all geo rules to update status of the rules.
-- =============================================
CREATE PROCEDURE [dbo].[spTPal_GRl_GetAllByOffenderID]
	@OffenderID	INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT g.GeoRuleID, 
		   s.GeoRuleScheduleID,
		   r.GeoRuleReferencePointId,
		   [state].Abbreviation,
		   r.PostalCode,
	       c.country,
	       f.ZoneID
FROM GeoRule g WITH (NOLOCK)
  INNER JOIN GeoRule_Offender f ON g.GeoRuleID = f.GeoRuleID
  LEFT JOIN GeoRuleSchedule s ON g.GeoRuleScheduleID = s.GeoRuleScheduleID
  LEft Join GEoRuleReferencePoint r on g.GeoRuleReferencePointId = r.GeoRuleReferencePointId
  left join dbo.[State] on [state].stateID = r.stateid
  left join country c on c.countryid = r.countryID 
WHERE f.OffenderID = @OffenderID 
  AND (g.UpdateInProgress = 1 OR g.StatusID = 3)
ORDER BY g.GeoRuleName
END

GO

GRANT EXECUTE ON [dbo].[spTPal_GRl_GetAllByOffenderID] TO db_dml;
GO

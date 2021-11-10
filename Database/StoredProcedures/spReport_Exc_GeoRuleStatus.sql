USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spReport_Exc_GeoRuleStatus]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spReport_Exc_GeoRuleStatus]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spReport_Exc_GeoRuleStatus.sql
 * Created On: 12/29/2010         
 * Created By: R.Cole  
 * Task #:     SA_1760      
 * Purpose:    Identify exceptions to TrackerPal/Gateway
 *             GeoRule Upload Status sync'ing.  Returns
 *             ONLY those Rules that do not have matching
 *             statuses.             
 *
 * Modified By: R.Cole - 7/22/2011: #2504 - Fixed an issue
 *                where the offenders last name was returned
 *                as the officers last name.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spReport_Exc_GeoRuleStatus] (
  @StartDate DATETIME = NULL
)
AS
SET NOCOUNT ON;
  
/* *** Status Mapping GW > TP *** 
  GW -1 / TP 2 = Inactive
  GW 0 / TP 3 = OK
  GW 1 / TP 4 = Pending
  GW 2 / TP 4 = Transferring
  GW 3 / TP 4 = Waiting
  ELSE TP 5 = Error
 * ****************************** */  
 
--DECLARE @StartDate DATETIME 
--SET @StartDate = NULL  
       
-- // Handle NULL StartDate Param // --
IF @StartDate IS NULL
  SET @StartDate = DATEADD(DAY, -1, GETDATE())   
   
-- // Main Query // --
SELECT Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName AS Officer,
       Offender.FirstName + ' ' + Offender.LastName AS Offender,
       GeoRule.GeoRuleName,
       GeoRule.CreatedDate,
       CASE act.[State] WHEN -1 THEN 2      -- Convert to TrackerPal GeoRuleStatus table values
                        WHEN 0 THEN 3
                        WHEN 1 THEN 4
                        WHEN 3 THEN 4
                        WHEN 4 THEN 4
                        ELSE 5
       END AS GatewayStatus,
       GeoRule.StatusID AS TrackerPalStatus
INTO #tmpGRExecReport
FROM GeoRule_Offender gro
  INNER JOIN GeoRule ON gro.GeoRuleID = GeoRule.GeoRuleID
  INNER JOIN Offender ON gro.OffenderID = Offender.OffenderID
  INNER JOIN Offender_Officer oo ON Offender.OffenderID = oo.OffenderID
  INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
  INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
  INNER JOIN Gateway.dbo.Actions act ON gro.ActionInstanceID = act.ActionInstanceID
WHERE GeoRule.CreatedDate >= @StartDate     -- Check all GeoRules created in the last day
GROUP BY Agency.Agency,
         Officer.FirstName + ' ' + Officer.LastName,
         Offender.FirstName + ' ' + Offender.LastName,
         GeoRule.GeoRuleName,         
         GeoRule.CreatedDate,
         act.[State],
         GeoRule.StatusID

-- // Return final results to report and alter for presentation// --         
SELECT Agency,
       Officer,
       Offender,
       GeoRuleName,
       CreatedDate,
       CASE GatewayStatus WHEN 2 THEN 'Inactive'
                          WHEN 3 THEN 'Active'
                          WHEN 4 THEN 'InProcess'
                          WHEN 5 THEN 'Error'
       END AS GWStatus,
       CASE TrackerPalStatus WHEN 2 THEN 'Inactive'
                             WHEN 3 THEN 'Active'
                             WHEN 4 THEN 'InProcess'
                             WHEN 5 THEN 'Error'
       END AS TPStatus
FROM #tmpGRExecReport
WHERE GatewayStatus <> TrackerPalStatus     -- Exceptions Only
ORDER BY Agency,
         Officer,
         Offender,
         GeoRuleName         

-- // Clean up // --
DROP TABLE #tmpGRExecReport
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spReport_Exc_GeoRuleStatus] TO db_dml;
GO
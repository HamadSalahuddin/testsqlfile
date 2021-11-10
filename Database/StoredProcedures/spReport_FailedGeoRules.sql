USE TrackerPal
GO
 
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spReport_FailedGeoRules]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spReport_FailedGeoRules]
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spReport_FailedGeoRules.sql
 * Created On: 08/11/2010
 * Created By: R.Cole  
 * Task #:     SA 1171      
 * Purpose:    Identify GeoRules that have either failed to 
 *             upload or error'd out.               
 *
 * Modified By: R.Cole - 12/14/2010 - Fixed a bug which
 *                was excluding some failed uploads.
 *              R.Cole - 3/30/2011 - Now looks back 2 days
 *                instead of 1, per ticket #2126
 *              R.Cole - 7/2/2012 - Added Cancelled to the list
 *                of 'failed' conditions.
 *              R.Cole - 7/10/2012 - Now looks back 1 day instead
 *                of 2.
 *              R.Cole - 9/10/2012 - Removed Timeouts, reduced
 *                timeframe to the past 2hrs.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spReport_FailedGeoRules] (
  @StartDate DATETIME = NULL 
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* ********* Dev Use Only *************** */
--DECLARE @StartDate DATETIME
--SET @StartDate = NULL        
 /* *********** End Dev Use *********** */
 
-- // Handle NULL StartDate Param // --
IF @StartDate IS NULL 
  SET @StartDate = DATEADD(HOUR, -2, GETDATE()) 

-- // Build tempTable // --
SELECT ah.ActionInstanceID,
       ah.DeviceID,
       ah.StartTime,
       CASE WHEN ah.[State] = 5 THEN 'Cancelled'
            WHEN ah.[State] = 8 THEN 'Error'             
       END AS 'Status'
INTO #tmpUploadErrors
FROM Gateway.dbo.ActionsHistory ah
  INNER JOIN Gateway.dbo.Files files ON ah.Payload = files.FileID
WHERE ah.StartTime >= @StartDate
  AND ah.ActionID = 16 
  AND files.[Type] = 2 
  AND ah.[State] IN (5,8)  
ORDER BY ah.ActionInstanceID DESC 

-- // Main Query // -- 
SELECT Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName AS Officer,
       Offender.FirstName + ' ' + Offender.LastName AS Offender,
       Tracker.TrackerID,
       Tracker.TrackerNumber,
       Tracker.TrackerName
FROM GeoRule_Offender
  INNER JOIN GeoRule ON GeoRule_Offender.GeoRuleID = GeoRule.GeoRuleID  
  LEFT JOIN Offender ON GeoRule_Offender.OffenderID = Offender.OffenderID
  LEFT JOIN Tracker ON Offender.TrackerID = Tracker.TrackerID
  LEFT JOIN #tmpUploadErrors up ON up.DeviceID = Tracker.TrackerID
  LEFT JOIN Agency ON Offender.AgencyID = Agency.AgencyID
  LEFT JOIN Offender_Officer oo ON Offender.OffenderID = oo.OffenderID
  LEFT JOIN Officer ON oo.OfficerID = Officer.OfficerID
WHERE GeoRule.CreatedDate >= @StartDate
  AND Tracker.TrackerID = up.DeviceID
  AND Tracker.TrackerName IS NOT NULL
  AND Tracker.CreatedDate = (SELECT MAX(CreatedDate) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID)
  AND (GeoRule.StatusID = 5 OR up.[Status] IN ('Cancelled','Error')) -- GeoRule.StatusID 5 = Failed
GROUP BY Agency.Agency,
         Officer.FirstName + ' ' + Officer.LastName, 
         Offender.FirstName + ' ' + Offender.LastName,
         Tracker.TrackerID,
         Tracker.TrackerNumber,
         Tracker.TrackerName
ORDER BY Agency.Agency,
         Officer.FirstName + ' ' + Officer.LastName, 
         Offender.FirstName + ' ' + Offender.LastName
  
-- // Clean Up // --  
DROP TABLE #tmpUploadErrors
GO

GRANT EXECUTE ON [dbo].[spReport_FailedGeoRules] TO db_dml;
GO
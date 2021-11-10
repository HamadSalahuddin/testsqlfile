USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spReport_BrokenGeoRules]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spReport_BrokenGeoRules]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spReport_BrokenGeoRules.sql
 * Created On: 7/1/2010         
 * Created By: R.Cole  
 * Task #:     905       
 * Purpose:    List of broken GeoRules for MC re-upload.
 *             Runs daily.               
 *    StatusID: 1 = New, 2 = NotUploaded-InActive, 3 = InProgress, 4 = Success, 5 = Failure      
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spReport_BrokenGeoRules] (
  @StartDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;

/* ********* Dev Use Only ***************
DECLARE @StartDate DATETIME
SET @StartDate = NULL         -- Manually enter the date in this format if running by hand: '06/25/2010 20:00:01'
 * *********** End Dev Use *********** */

-- // Handle NULL StartDate Param // --
IF @StartDate IS NULL
  SET @StartDate = DATEADD(DAY, -1, GETDATE()) 

-- // Build tempTable // --
SELECT OffenderID,
       AreaID,
       StatusID
INTO #tmpUploads
FROM GeoRule_Offender
  INNER JOIN GeoRule ON GeoRule_Offender.GeoRuleID = GeoRule.GeoRuleID
WHERE GeoRule.CreatedDate >= @StartDate
GROUP BY OffenderID, 
         AreaID, 
         StatusID
ORDER BY OffenderID
        
-- // Main Query // --        
SELECT Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName AS Officer,
       Offender.FirstName + ' ' + Offender.LastName AS Offender,
       GeoRule.GeoRuleName,
       Tracker.TrackerID,
       Tracker.TrackerNumber,
       Tracker.TrackerName --,
--       GeoRule_Offender.AreaID,     -- Dev use
--       GeoRule.StatusID             -- Dev use
FROM GeoRule_Offender
  INNER JOIN GeoRule ON GeoRule_Offender.GeoRuleID = GeoRule.GeoRuleID
  LEFT JOIN #tmpUploads up ON up.OffenderID = GeoRule_Offender.OffenderID
  LEFT JOIN Offender ON GeoRule_Offender.OffenderID = Offender.OffenderID
  LEFT JOIN Tracker ON Offender.TrackerID = Tracker.TrackerID
  LEFT JOIN Agency ON Offender.AgencyID = Agency.AgencyID
  LEFT JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
  LEFT JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
WHERE GeoRule.CreatedDate >= @StartDate
  AND GeoRule_Offender.OffenderID = up.OffenderID
  AND ((GeoRule_Offender.AreaID = up.AreaID) AND (GeoRule.StatusID <> up.StatusID))   -- db 'Footprint' of the issue
  AND Tracker.TrackerName IS NOT NULL
  AND Tracker.CreatedDate = (SELECT MAX(CreatedDate) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID) 
GROUP BY Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName, 
       Offender.FirstName + ' ' + Offender.LastName,
       GeoRule.GeoRuleName,
--       GeoRule_Offender.AreaID,     -- Dev use
--       GeoRule.StatusID,            -- Dev use
       Tracker.TrackerID,
       Tracker.TrackerNumber,
       Tracker.TrackerName
ORDER BY Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName, 
       Offender.FirstName + ' ' + Offender.LastName
  
-- // Clean Up // --  
DROP TABLE #tmpUploads
GO

GRANT EXECUTE ON [dbo].[spReport_BrokenGeoRules] TO db_dml;
GO
USE TrackerPal
GO
 
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Exc_GeoRuleTimeout]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Exc_GeoRuleTimeout]
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Exc_GeoRuleTimeout.sql
 * Created On: 09/10/2012
 * Created By: R.Cole  
 * Task #:     3649      
 * Purpose:    Identify GeoRules that have timed out
 *
 * Modified By: 
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Exc_GeoRuleTimeout] (
  @StartDate DATETIME = NULL 
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* ********* Dev Use Only *************** */
--DECLARE @StartDate DATETIME
--SET @StartDate = NULL        
 /* *********** End Dev Use *********** */

DECLARE @tUploadTimeouts TABLE (
  ActionInstanceID INT,
  DeviceID INT,
  StartTime DATETIME,
  [Status] VARCHAR(7)
)

-- // Handle NULL StartDate Param // --
IF @StartDate IS NULL 
  SET @StartDate = DATEADD(DAY, -1, GETDATE()) 

-- // Build tempTable // --
INSERT INTO @tUploadTimeouts (ActionInstanceID, DeviceID, StartTime, [Status])
  SELECT ah.ActionInstanceID,
         ah.DeviceID,
         ah.StartTime,
         CASE WHEN ah.[State] = 6 THEN 'Timeout' END AS 'Status'
--INTO #tmpUploadTimeout
  FROM Gateway.dbo.ActionsHistory ah
    INNER JOIN Gateway.dbo.Files files ON ah.Payload = files.FileID
  WHERE ah.StartTime >= @StartDate
    AND ah.ActionID = 16 
    AND files.[Type] = 2 
    AND ah.[State] = 6
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
  LEFT JOIN @tUploadTimeouts ut ON ut.DeviceID = Tracker.TrackerID
  LEFT JOIN Agency ON Offender.AgencyID = Agency.AgencyID
  LEFT JOIN Offender_Officer oo ON Offender.OffenderID = oo.OffenderID
  LEFT JOIN Officer ON oo.OfficerID = Officer.OfficerID
WHERE GeoRule.CreatedDate >= @StartDate
  AND Tracker.TrackerID = ut.DeviceID
  AND Tracker.TrackerName IS NOT NULL
  AND Tracker.CreatedDate = (SELECT MAX(CreatedDate) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID)
  AND ut.[Status] LIKE 'Timeout'
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
--DROP TABLE #tmpUploadTimeout
GO

GRANT EXECUTE ON [dbo].[spTPal_Exc_GeoRuleTimeout] TO db_dml;
GO
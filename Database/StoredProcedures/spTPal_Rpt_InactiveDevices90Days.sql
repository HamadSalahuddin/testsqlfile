USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_InactiveDevices90Days]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_InactiveDevices90Days]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_InactiveDevices90Days.sql
 * Created On: 10/15/2012
 * Created By: R.Cole
 * Task #:     3713
 * Purpose:    Identify those devices that have had no activity
 *             for more than 90 days.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_InactiveDevices90Days] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Set up variables // --
DECLARE @UTCOffset INT,
        @RunDate CHAR(10),
        @Now DATETIME

SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
SET @Now = GETDATE()
SET @RunDate = CONVERT(CHAR(10), DATEADD(MINUTE, @UTCOffset, @Now), 110)

-- // Main Query // --
SELECT DISTINCT Tracker.TrackerID,
        LEFT(Tracker.TrackerName,8) AS [SerialNum],
        Agency.Agency,
        (CASE WHEN ota.DeactivateDate IS NOT NULL THEN CONVERT(CHAR(10),DATEDIFF(DAY, ota.DeactivateDate, @Now),110) END) AS [IdleDays],
        CONVERT(CHAR(10),DATEADD(MINUTE, @UTCOffset, Tracker.CreatedDate),110) AS [Assigned To Agency],
        CONVERT(CHAR(10),DATEADD(MINUTE, @UTCOffset, ota.ActivateDate),110) AS [Last Activated],
        CONVERT(CHAR(10),DATEADD(MINUTE, @UTCOffset, ota.DeactivateDate),110) AS [Last Used],
        (CASE WHEN Tracker.RMAID IS NOT NULL THEN CONVERT(CHAR(10),DATEADD(MINUTE, @UTCOffset, TrackerRMA.CreatedDate),110) END) AS [RMA Created],
        @RunDate AS [RunDate]
FROM Tracker
  INNER JOIN Agency ON Tracker.AgencyID = Agency.AgencyID
  LEFT OUTER JOIN OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
  LEFT OUTER JOIN Offender ON ota.OffenderID = Offender.OffenderID
  LEFT OUTER JOIN TrackerRMA ON Tracker.RMAID = TrackerRMA.RMAID
WHERE TrackerUniqueID = (SELECT MAX(TrackerUniqueID) 
                         FROM Tracker t                          
                         WHERE t.TrackerID = Tracker.TrackerID
                           AND t.AgencyID = Tracker.AgencyID)
  AND TrackerActivationID = (SELECT MAX(TrackerActivationID)
                             FROM OffenderTrackerActivation ta
                             WHERE ta.TrackerID = Tracker.TrackerID)
  AND Tracker.Deleted = 0
  AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)
  AND Offender.AgencyID = Tracker.AgencyID
  AND ota.DeactivateDate IS NOT NULL
GROUP BY Agency.Agency,
         Tracker.TrackerID,
         LEFT(Tracker.TrackerName,8),
         ota.DeactivateDate,
         DATEADD(MINUTE, @UTCOffset,Tracker.CreatedDate),
         DATEADD(MINUTE, @UTCOffset,ota.ActivateDate),
         DATEADD(MINUTE, @UTCOffset,ota.DeactivateDate),
         Tracker.RMAID,
         TrackerRMA.CreatedDate
HAVING ((CASE WHEN ota.DeactivateDate IS NOT NULL THEN DATEDIFF(DAY, ota.DeactivateDate, @Now) END) >= 90) 
ORDER BY Agency.Agency
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_InactiveDevices90Days] TO db_dml;
GO
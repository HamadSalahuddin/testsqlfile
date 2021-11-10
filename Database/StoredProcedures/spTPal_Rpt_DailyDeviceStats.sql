USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_DailyDeviceStats]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_DailyDeviceStats]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_DailyDeviceStats.sql
 * Created On: 11/7/2012         
 * Created By: R.Cole
 * Task #:     3743
 * Purpose:    Return various device reporting metrics to a 
 *             daily automated report.  TimeFrame = last 24hrs               
 *
 * Modified By: R.Cole - 11/13/2012: Fixed an overrun issue with
 *  @DuplicateEventsPerMinute.  Added some UTCOffset logic in 
 *  several locations where it was missing.  Added 3 more
 *  EventID's to the filters (256,257,258)
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_DailyDeviceStats] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Set up Vars // --
DECLARE @StartDate DATETIME,
        @EndDate DATETIME,
        @NonComms INT,
        @CommResumes INT,
        @DuplicateEvents INT,
        @DuplicateEventsPerMinute DECIMAL(6,2),
        @DevicesReporting INT,
        @ReportDate CHAR(10),
        @UTCOffset INT

-- // Set up Table Vars // --
DECLARE @tblDuplicateEvents TABLE (
  DeviceID INT,
  Serial NVARCHAR(25),
  IMEI NVARCHAR(25),
  ICCID NVARCHAR(25),
  LastEvent_MT DATETIME,
  Duplicates INT
)

DECLARE @tblDevicesReporting TABLE (
  DeviceID INT,
  SerialNum NVARCHAR(25),
  Agency NVARCHAR(250)
)

-- // Set Dates // --
SET @UTCOffset = TrackerPal.dbo.fnGetMSTOffset(8)  -- MountainTime
SET @ReportDate = CONVERT(CHAR(10), DATEADD(mi, @UTCOffset, GETDATE()),110)

SET @StartDate = DATEADD(HH,-24,DATEADD(mi, @UTCOffset, GETDATE()))
SET @EndDate = DATEADD(MI, @UTCOffset, GETDATE())
   
-- // Get Duplicate Events // --
INSERT INTO @tblDuplicateEvents (
  DeviceID,
  Serial,
  IMEI,
  ICCID,
  LastEvent_MT,
  Duplicates
)
SELECT DISTINCT Devices.DeviceID,
       dp.PropertyValue AS Serial,
       dp1.PropertyValue AS IMEI,
       dp2.PropertyValue AS ICCID,
       DATEADD(MI, @UTCOffset, Gateway.dbo.ConvertLongToDate(Devices.LastEventTime)) AS LastEvent_MT,
       COUNT(Sequence) AS Duplicates
FROM Gateway.dbo.Devices
  INNER JOIN Gateway.dbo.DeviceProperties dp ON Devices.DeviceID = dp.DeviceID AND dp.PropertyID LIKE '8012'    -- S/N
  INNER JOIN Gateway.dbo.DeviceProperties dp1 ON Devices.DeviceID = dp1.DeviceID AND dp1.PropertyID LIKE '8205' -- IMEI
  INNER JOIN Gateway.dbo.DeviceProperties dp2 ON Devices.DeviceID = dp2.DeviceID AND dp2.PropertyID LIKE '8204' -- ICCID
  INNER JOIN Gateway.dbo.DuplicateEvents de ON Devices.DeviceID = de.DeviceID
WHERE DATEADD(MI, @UTCOffset, de.TransmittedTime) BETWEEN @StartDate AND @EndDate
GROUP BY Devices.DeviceID,
         dp.PropertyValue,
         dp1.PropertyValue,
         dp2.PropertyValue,
         Devices.LastEventTime
ORDER BY dp.PropertyValue,
         DATEADD(MI, @UTCOffset, Gateway.dbo.ConvertLongToDate(Devices.LastEventTime))

-- // Get Non-Comms // --
SET @NonComms = (SELECT COUNT(evt.EventID) 
                 FROM Gateway.dbo.Events evt
                   INNER JOIN Gateway.dbo.Devices dev ON evt.DeviceID = dev.DeviceID
                   INNER JOIN TrackerPal.dbo.Tracker ON dev.DeviceID = Tracker.TrackerID
                   INNER JOIN TrackerPal.dbo.OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
                   INNER JOIN TrackerPal.dbo.Agency ag ON Tracker.AgencyID = ag.AgencyID
                 WHERE evt.EventID = 258 
                   AND DATEADD(MI, @UTCOffset, evt.TransmittedTime) BETWEEN @StartDate AND @EndDate 
                   AND ((ota.DeactivateDate IS NULL) OR (ota.DeactivateDate BETWEEN @StartDate AND @EndDate))
                   AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID)
                                                  FROM TrackerPal.dbo.Tracker t
                                                  WHERE t.TrackerID = dev.DeviceID)  
                   AND ag.AgencyID IN (20,21,22,23,24,26,27,28,30))                       -- Islas Agencies

-- // Get CommResumes // --
SET @CommResumes = (SELECT COUNT(evt.EventID) 
                    FROM Gateway.dbo.Events evt 
                      INNER JOIN Gateway.dbo.Devices dev ON evt.DeviceID = dev.DeviceID
                      INNER JOIN TrackerPal.dbo.Tracker ON dev.DeviceID = Tracker.TrackerID
                      INNER JOIN TrackerPal.dbo.OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
                      INNER JOIN TrackerPal.dbo.Agency ag ON Tracker.AgencyID = ag.AgencyID
                    WHERE evt.EventID = 257 
                      AND DATEADD(MI, @UTCOffset, evt.TransmittedTime) BETWEEN @StartDate AND @EndDate 
                      AND ((ota.DeactivateDate IS NULL) OR (DATEADD(MI, @UTCOffset,ota.DeactivateDate) BETWEEN @StartDate AND @EndDate))
                      AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID)
                                                     FROM TrackerPal.dbo.Tracker t
                                                     WHERE t.TrackerID = dev.DeviceID)
                      AND ag.AgencyID IN (20,21,22,23,24,26,27,28,30))                   -- Islas Agencies

-- // Get Reporting Devices // --
INSERT INTO @tblDevicesReporting (
  DeviceID,
  SerialNum,
  Agency
)
SELECT DISTINCT Devices.DeviceID,
       dp.PropertyValue AS SerialNum,
       ag.Agency
FROM Gateway.dbo.Devices 
  INNER JOIN TrackerPal.dbo.Tracker ON Devices.DeviceID = Tracker.TrackerID
  INNER JOIN Gateway.dbo.DeviceProperties dp ON Devices.DeviceID = dp.DeviceID AND dp.PropertyID = '8012' -- SN
  INNER JOIN Gateway.dbo.Events evt ON Devices.DeviceID = evt.DeviceID
  INNER JOIN TrackerPal.dbo.OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
  INNER JOIN TrackerPal.dbo.Agency ag ON Tracker.AgencyID = ag.AgencyID
WHERE DATEADD(MI, @UTCOffset, evt.TransmittedTime) BETWEEN @StartDate and @EndDate
  AND ((ota.DeactivateDate IS NULL) OR (DATEADD(MI, @UTCOffset, ota.DeactivateDate) BETWEEN @StartDate AND @EndDate))
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) 
                                 FROM TrackerPal.dbo.Tracker t
                                 WHERE t.TrackerID = Devices.DeviceID)
  AND evt.EventID NOT IN (255,256,257,258)
  AND ag.AgencyID IN (20,21,22,23,24,26,27,28,30)                                     -- Islas Agencies

-- // Gather summary data // --
-- Perform calc's one time only rather than once per row
SET @DuplicateEvents = (SELECT SUM(Duplicates) FROM @tblDuplicateEvents)
SET @DuplicateEventsPerMinute = ((@DuplicateEvents / 24) / 60)
SET @DevicesReporting = (SELECT COUNT(DISTINCT DeviceID) FROM @tblDevicesReporting)

-- // Return results // --
SELECT @DuplicateEvents AS DuplicateEvents,
       @DuplicateEventsPerMinute AS DuplicateEventsPerMinute,
       @DevicesReporting AS DevicesReporting,
       @NonComms AS NonCommEvents,
       @CommResumes AS CommResumeEvents,
       DeviceID AS DeviceGID,
       SerialNum AS SerialNum,
       Agency AS Agency,
       @ReportDate AS ReportDate
FROM @tblDevicesReporting
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_DailyDeviceStats] TO db_dml;
GO
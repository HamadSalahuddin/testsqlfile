USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AlarmEnforcement]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AlarmEnforcement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AlarmEnforcement.sql
 * Created On: 04/02/2013
 * Created By: R.Cole
 * Task #:     4022
 * Purpose:    Automated "Enforcement" report which display's
 *             Islas offenders with possible charging or other
 *             device related issues.
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AlarmEnforcement] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
-- // Declare Var's // --
DECLARE @UTCOffset INT,
        @Now DATETIME,
        @RunDate CHAR(10),
        @StartDate DATETIME,
        @RunTime CHAR(8) -- 23:59:59

-- // Set up Table Variable // --
DECLARE @tblLastEvents TABLE (
  [DeviceID] [INT] NOT NULL,
  [LastEventTime] [BIGINT] NOT NULL,
  [InternalBatteryVoltage] [SMALLINT] NULL
)

DECLARE @tblBattery TABLE (
  [TrackerID] INT,
  [Device] NVARCHAR(20),
  [IslasID] NVARCHAR(50),
  [FirstName] NVARCHAR(50),
  [Agency] NVARCHAR(50),
  [Officer] NVARCHAR(100),
  [Alarm] NVARCHAR(50),
  [RunningTotal] INT,
  [LastEventTime] BIGINT,
  [CurrentlyReporting] BIT,
  [LastEvent_MT] DATETIME
)

-- // Set UTCOffset // --
SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
SET @Now = GETDATE()
        
-- // Set Report RunDate and RuntTime // --
SET @RunDate = CONVERT(CHAR(10),DATEADD(mi,@UTCOffset,@Now),103)
SET @RunTime = CONVERT(CHAR(8),DATEADD(MI, @UTCOffset,@Now),8)

-- // Get FirstDay of Current Month (in MT) // --
SET @StartDate = (SELECT CONVERT(VARCHAR(25), DATEADD(dd, -(DAY(DATEADD(MI, @UTCOffset, @Now))-1), DATEADD(MI, @UTCOffset, @Now)), 101))
   
-- // Main Query // --
INSERT INTO @tblBattery (
  TrackerID, 
  Device, 
  IslasID, 
  FirstName, 
  Agency, 
  Officer, 
  Alarm, 
  RunningTotal, 
  LastEventTime, 
  CurrentlyReporting, 
  LastEvent_MT
)
SELECT DISTINCT Tracker.TrackerID,
       dp.PropertyValue AS 'Device',                                            -- S/N
       Offender.LastName AS 'IslasID',                                          -- Offender's IslasID
       Offender.FirstName AS 'FirstName',    
       Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName AS 'Officer',                                        
       EventType.AbbrevEventType AS Alarm,
       COUNT(DISTINCT(AlarmID)) AS 'RunningTotal',
       gwDev.LastEventTime,
       CASE WHEN DATEDIFF(MINUTE, dbo.ConvertLongToDate(gwDev.LastEventTime), GETDATE()) > 30 THEN '0' ELSE '1' END AS 'CurrentlyReporting',
       DATEADD(MI, @UTCOffset, dbo.ConvertLongToDate(gwDev.LastEventTime)) AS LastEvent_MT
FROM Alarm WITH (NOLOCK)
  INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
  INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
  INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
  INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
  INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
  INNER JOIN Tracker ON Alarm.TrackerID = Tracker.TrackerID
  INNER JOIN OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
  INNER JOIN Gateway.dbo.Devices gwDev ON Tracker.TrackerID = gwDev.DeviceID
  INNER JOIN Gateway.dbo.DeviceProperties dp ON gwDev.DeviceID = dp.DeviceID AND PropertyID = '8012'
  INNER JOIN Gateway.dbo.Events (NOLOCK) gwEvents ON Alarm.TrackerID = gwEvents.DeviceID
	         AND Alarm.EventTypeID = gwEvents.EventID
	         AND Alarm.EventTime = gwEvents.EventTime
WHERE Agency.AgencyID = 35                                                      -- SEGOB
  AND DATEADD(MI, @UTCOffset,Alarm.EventDisplayTime) >= @StartDate
  AND gwEvents.EventID IN (210,211,212)                                         -- Battery Events ONLY
GROUP BY Tracker.TrackerID,
         dp.PropertyValue,
         Offender.LastName,
         Offender.FirstName,
         EventType.AbbrevEventType,
         gwDev.LastEventTime,
         Agency.Agency,
         Officer.FirstName + ' ' + Officer.LastName
ORDER BY dp.PropertyValue,
         Offender.LastName,
         EventType.AbbrevEventType

-- // Get battery level of lastevent // --
INSERT INTO @tblLastEvents (
  DeviceID,
  LastEventTime,
  InternalBatteryVoltage
)
SELECT DISTINCT batt.TrackerID,
       batt.LastEventTime,
       evt.InternalBatteryVoltage
FROM @tblBattery batt
  INNER JOIN Gateway.dbo.Events evt ON batt.TrackerID = evt.DeviceID
         AND batt.LastEventTime = evt.EventTime

-- // Get Final Results // --
SELECT TrackerID,
       Device,
       IslasID,
       FirstName,
       Agency,
       Officer,
       Alarm,
       RunningTotal,
       CASE WHEN CurrentlyReporting = 1 THEN 'Yes' ELSE 'NO' END AS CurrentlyReporting,
       CASE WHEN CurrentlyReporting = 0 THEN LastEvent_MT ELSE NULL END AS LastEvent_MT,
--       evtFinal.InternalBatteryVoltage,
       CONVERT(CHAR(10), @StartDate ,103) AS StartDate,
       @RunDate AS RunDate,
       @RunTime AS RunTime
FROM @tblBattery battFinal
  INNER JOIN @tblLastEvents evtFinal ON battFinal.TrackerID = evtFinal.DeviceID
         AND battFinal.LastEventTime = evtFinal.LastEventTime
WHERE evtFinal.InternalBatteryVoltage < 3856 -- 50% 3770 --3856 60% --4028 = 80%
--  AND dbo.ConvertLongToDate(BattFinal.LastEventTime) > DATEADD(DAY, -1, @Now)
--   OR CurrentlyReporting = 0
--   AND CurrentlyReporting = 1

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AlarmEnforcement] TO db_dml;
GO
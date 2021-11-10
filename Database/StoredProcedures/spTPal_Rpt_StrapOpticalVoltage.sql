USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_StrapOpticalVoltage]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_StrapOpticalVoltage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_StrapOpticalVoltage.sql
 * Created On: 8/13/2012
 * Created By: R.Cole
 * Task #:     3435
 * Purpose:    Return dataset to report               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_StrapOpticalVoltage] (
  @StartDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--DECLARE @StartDate DATETIME
--SET @StartDate = NULL
   
DECLARE @UtcOffset INT
SET @UtcOffset = dbo.fnGetMSTOffset(8)  -- MountainTime

-- // Handle NULL Date Param and Adjust StartDate to MT // --
IF @StartDate IS NULL
  SET @StartDate = CONVERT(CHAR(10), GETDATE(), 23)
ELSE
  SET @StartDate = CONVERT(CHAR(10), @StartDate, 23)

-- // Main Query // --
SELECT dp.PropertyValue AS [SerialNum],
       CONVERT(CHAR(25),DATEADD(MI, @UtcOffset, Alarm.EventDisplayTime), 121) AS [AlarmTime_MT],
       Gateway.dbo.HexToSmallInt(dp1.PropertyValue) AS [FirmwareVersion],
       gwEvents.ExternalBatteryVoltage,
       gwEvents.InternalBatteryVoltage,
       Agency.Agency,
       Offender.FirstName + ' ' + Offender.LastName AS [Offender]
FROM TrackerPal.dbo.Alarm Alarm
  LEFT OUTER JOIN Gateway.dbo.Events gwEvents ON Alarm.TrackerID = gwEvents.DeviceID
              AND Alarm.EventTypeID = gwEvents.EventID
              AND Alarm.EventTime = gwEvents.EventTime
  INNER JOIN TrackerPal.dbo.Tracker ON Alarm.TrackerID = Tracker.TrackerID
	INNER JOIN Trackerpal.dbo.OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON Alarm.TrackerID = dp.DeviceID AND dp.PropertyID = '8012' --S/N
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp1 ON Alarm.TrackerID = dp1.DeviceID AND dp1.PropertyID = '8016'   -- Firmware Rev.
	INNER JOIN TrackerPal.dbo.Offender ON ota.OffenderID = Offender.OffenderID
	INNER JOIN TrackerPal.dbo.Agency ON Offender.AgencyID = Agency.AgencyID
WHERE Alarm.EventTypeID = 65
  AND CONVERT(CHAR(10),DATEADD(MI, @UtcOffset,Alarm.EventDisplayTime),23) = @StartDate
  AND ota.DeactivateDate IS NULL
	AND Tracker.Deleted = 0
	AND Tracker.AgencyID <> 1
	AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)  -- // This is not applicable for Int'l servers // --
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker WHERE TrackerID = ota.TrackerID)
  AND Gateway.dbo.HexToSmallInt(dp1.PropertyValue) >= 1674
ORDER BY dp.PropertyValue,
         CONVERT(CHAR(25),DATEADD(MI, @UtcOffset, Alarm.EventDisplayTime), 121)
         
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_StrapOpticalVoltage] TO db_dml;
GO
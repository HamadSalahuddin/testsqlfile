USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Agn_GetOffenderRollCallList]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Agn_GetOffenderRollCallList]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Agn_GetOffenderRollCallList.sql
 * Created On: 12/04/2012
 * Created By: R.Cole
 * Task #:     #3793
 * Purpose:    Return a list of active offenders for a specified
 *             agency               
 *
 * Modified By: R.Cole - 04/12/2013: Added new param: @OfficerID
 *              and added code to handle returning data for 
 *              all officers in an agency or a single officer.
 *              R.Cole - 04/19/2013: Added two new fields to 
 *              the resultset.  LastEventTime and BatteryVoltage
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Agn_GetOffenderRollCallList] (
  @AgencyID INT,
  @RollCall DATETIME,                   -- *** WARNING!!!! *** User Time *NOT* UTC!
  @GracePeriod INT,
  @TimeZoneID INT,
  @OfficerID INT = -1
) 
AS
SET NOCOUNT ON;

--*********************************
/*  
DECLARE @AgencyID INT,
        @RollCall DATETIME,
        @GracePeriod INT,
        @TimeZoneID INT,
        @OfficerID INT

SET @AgencyID = 35
SET @RollCall = '2013-04-19 17:00:00.000'--GETDATE()
--SET @RollCall = DATEADD(DAY, -1, GETDATE())
SET @GracePeriod = 10
SET @TimeZoneID = 8
SET @OfficerID = -1
*/
--*********************************

-- // Var's // --
DECLARE @StartDate DATETIME,
        @EndDate DATETIME,
        @UTCOffset INT

-- // Set up dates // --
SET @UTCOffset = dbo.fnGetUTCOffsetByTimeZoneID(@TimeZoneID, @RollCall)

-- // Setup Grace Period // --
SET @StartDate = DATEADD(MI, -@GracePeriod, @RollCall)
SET @EndDate = DATEADD(MI, @GracePeriod, @RollCall)

--SELECT @RollCall, @UTCOffset, @GracePeriod, @StartDate, @EndDate

-- // Main Query // --
IF DATEDIFF(DAY, @RollCall, GETDATE()) >= 1                              -- Determine if we are doing a historical search
  BEGIN     -- Historical data    
    IF @OfficerID = -1
      BEGIN
        -- Get data for all officers in the agency
        SELECT DISTINCT Offender.OffenderID,
                Offender.LastName + ', ' + Offender.FirstName AS OffenderName,
                Agency.Agency AS [Camp],
                Officer.FirstName + ' ' + Officer.LastName AS [Division],
                dp.PropertyValue AS DeviceSN,
                DATEADD(MI, @UTCOffset, dbo.ConvertLongToDate(dev.LastEventTime)) AS LastEventTime,
                evt.InternalBatteryVoltage AS BatteryVoltage
        FROM Offender
          INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
          INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
          INNER JOIN Offender_Officer oo ON Offender.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON ota.TrackerID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012'
          INNER JOIN Gateway.dbo.Events evt ON dev.DeviceID = evt.DeviceID
                 AND dev.LastEventTime = evt.EventTime
        WHERE Offender.AgencyID = @AgencyID
          AND DATEADD(MI, @UTCOffset, ota.ActivateDate) <= @StartDate 
          AND ((DATEADD(MI, @UTCOffset, ota.DeactivateDate) >= @EndDate) OR (ota.DeactivateDate IS NULL))
          AND Offender.Deleted = 0
      END
    ELSE
      BEGIN
        -- Get data for specific Officer
        SELECT DISTINCT Offender.OffenderID,
                Offender.LastName + ', ' + Offender.FirstName AS OffenderName,
                Agency.Agency AS [Camp],
                Officer.FirstName + ' ' + Officer.LastName AS [Division],
                dp.PropertyValue AS DeviceSN,
                DATEADD(MI, @UTCOffset, dbo.ConvertLongToDate(dev.LastEventTime)) AS LastEventTime,
                evt.InternalBatteryVoltage AS BatteryVoltage
        FROM Offender
          INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
          INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
          INNER JOIN Offender_Officer oo ON Offender.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON ota.TrackerID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012'
          INNER JOIN Gateway.dbo.Events evt ON dev.DeviceID = evt.DeviceID
                 AND dev.LastEventTime = evt.EventTime
        WHERE Officer.OfficerID = @OfficerID
          AND DATEADD(MI, @UTCOffset, ota.ActivateDate) <= @StartDate 
          AND ((DATEADD(MI, @UTCOffset, ota.DeactivateDate) >= @EndDate) OR (ota.DeactivateDate IS NULL))
          AND Offender.Deleted = 0
      END
  END
ELSE 
  BEGIN    -- Realtime data
    IF @OfficerID = -1
      BEGIN
        -- Get data for officers in the agency
        SELECT DISTINCT Offender.OffenderID,
               Offender.LastName + ', ' + Offender.FirstName AS OffenderName,
               Agency.Agency AS [Camp],
               Officer.FirstName + ' ' + Officer.LastName AS [Division],
               dp.PropertyValue AS DeviceSN,
               DATEADD(MI, @UTCOffset, dbo.ConvertLongToDate(dev.LastEventTime)) AS LastEventTime,
               evt.InternalBatteryVoltage AS BatteryVoltage
        FROM Offender
          INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
          INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
          INNER JOIN Offender_Officer oo ON Offender.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON ota.TrackerID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012'
          INNER JOIN Gateway.dbo.Events evt ON dev.DeviceID = evt.DeviceID
                 AND dev.LastEventTime = evt.EventTime
        WHERE Offender.AgencyID = @AgencyID
          AND ota.DeactivateDate IS NULL 
          AND Offender.Deleted = 0
      END
    ELSE
      BEGIN
        -- Get data for specific Officer
        SELECT DISTINCT Offender.OffenderID,
               Offender.LastName + ', ' + Offender.FirstName AS OffenderName,
               Agency.Agency AS [Camp],
               Officer.FirstName + ' ' + Officer.LastName AS [Division],
               dp.PropertyValue AS DeviceSN,
               DATEADD(MI, @UTCOffset, dbo.ConvertLongToDate(dev.LastEventTime)) AS LastEventTime,
               evt.InternalBatteryVoltage AS BatteryVoltage
        FROM Offender
          INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
          INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
          INNER JOIN Offender_Officer oo ON Offender.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON ota.TrackerID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012'
          INNER JOIN Gateway.dbo.Events evt ON dev.DeviceID = evt.DeviceID
                 AND dev.LastEventTime = evt.EventTime
        WHERE Officer.OfficerID = @OfficerID
          AND ota.DeactivateDate IS NULL 
          AND Offender.Deleted = 0
      END

  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Agn_GetOffenderRollCallList] TO db_dml;
GO
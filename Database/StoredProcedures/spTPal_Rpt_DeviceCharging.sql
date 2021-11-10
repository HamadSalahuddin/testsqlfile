USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_DeviceCharging]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_DeviceCharging]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_DeviceCharging.sql
 * Created On: 04/11/2012
 * Created By: R.Cole
 * Task #:     #2650
 * Purpose:    Populate the Device Charging report.  
 *
 * Modified By: R.Cole - 5/22/2012: Per #3356, revised offender/officer names,
 *      added some additional date checks.
 *              R.Cole - 6/5/2012: Added code to account for
 *      offender that do not have an EventID 218 which resulted
 *      in them being excluded from the results.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_DeviceCharging] (
  @OfficerID INT,
  @AgencyID INT,
  @DistributorID INT = NULL,          -- Handle Distributors
  @RoleID INT = NULL,                 -- Handle Application Admins
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* 
---------- Staging TEST DATA ------------
DECLARE @OfficerID INT,
        @AgencyID INT,
        @DistributorID INT,
        @RoleID INT,
        @StartDate DATETIME,
        @EndDate DATETIME
        
--SET @OffenderID = 64906--20710 --64906
SET @OfficerID = 5740
SET @AgencyID = 1112      -- CPI - Orlando
SET @DistributorID = -1 -- CPI
SET @RoleID = 0
SET @StartDate = '2012-06-03'
SET @EndDate = '2012-06-05'
-----------------------------------------
*/

DECLARE @RunDate CHAR(10),
        @UTCOffset INT

-- Set up Cursor Var's
DECLARE @Offender INT,
        @EvtID INT,
        @Time DATETIME,
        @ChargeStartTime DATETIME,
        @Duration INT

-- // Handle UTCOffsets based on who is running the report // --
IF @DistributorID > 0 --IS NOT NULL                                       -- Distributor User
  SET @UTCOffset = dbo.fnGetDistributorUtcOffset(@DistributorID)
ELSE IF @RoleID = 4                                                       -- App Admin/SuperUser
  SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
ELSE                                                                      -- Agency User
  SET @UTCOffset = dbo.fnGetUtcOffset(@AgencyID)

-- // Set Report RunDate // --
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi, @UTCOffset, GETDATE()),110)

-- // Account for NULL Date Params: Default to last 48hrs // --
IF ((@StartDate IS NULL) OR (@EndDate IS NULL))
  BEGIN
    SET @StartDate = DATEADD(HOUR, -48, DATEADD(mi, @UTCOffset, GETDATE()))
    SET @EndDate = DATEADD(MI, @UTCOffset, GETDATE())
  END   

-- // Setup Table Variable // --
DECLARE @BatteryEvents TABLE (
  OffenderID INT,
  SerialNumber NVARCHAR(8),
  Offender NVARCHAR(100),
  AgencyID INT,
  Agency NVARCHAR(100),
  OfficerID INT,
  Officer NVARCHAR(100),
  TransTime DATETIME,
  EventID INT,
  EventTime DATETIME,
  ChargeStart DATETIME NULL,
  ChargeDuration INT NULL
)

-- // Populate Table Variable // -- 
INSERT INTO @BatteryEvents (
  OffenderID,
  SerialNumber,
  Offender,
  AgencyID,
  Agency,
  OfficerID,
  Officer,
  TransTime,
  EventID,
  EventTime
)
SELECT DISTINCT Offender.OffenderID, 
       LEFT(TrackerName,8) AS [SerialNumber],
       Offender.LastName + ', ' + Offender.FirstName AS [Offender],
--       Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS [Offender],
       Agency.AgencyID,
       Agency.Agency,
       Officer.OfficerID,
       Officer.LastName + ', ' + Officer.FirstName AS [Officer],
--       Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS [Officer],
       DATEADD(mi,@UTCOffset,gwEvents.TransmittedTime) AS [TransTime],
       gwEvents.EventID,
       DATEADD(mi, @UTCOffset,dbo.ConvertLongToDate(gwEvents.EventTime)) AS [EventTime]
FROM Gateway.dbo.Events gwEvents WITH (NOLOCK)
  INNER JOIN Gateway.dbo.EventTypes gwEventTypes ON gwEvents.EventID = gwEventTypes.EventID
  INNER JOIN Tracker ON gwEvents.DeviceID = Tracker.TrackerID
  INNER JOIN OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
  INNER JOIN Offender ON ota.OffenderID = Offender.OffenderID
  INNER JOIN Officer ON ota.OfficerID = Officer.OfficerID
  INNER JOIN Agency ON Tracker.AgencyID = Agency.AgencyID
WHERE Officer.OfficerID = @OfficerID
  AND gwEvents.EventID IN (217,218)
  AND DATEADD(mi, @UTCOffset, gwEvents.TransmittedTime) BETWEEN @StartDate AND @EndDate
  AND DATEADD(MI,@UTCOffset, ota.ActivateDate) < @EndDate
  AND (DATEADD(mi,@UTCOffset, ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker WHERE TrackerID = ota.TrackerID)    
ORDER BY Offender.OffenderID ASC,
         DATEADD(mi, @UTCOffset,dbo.ConvertLongToDate(gwEvents.EventTime)) ASC

-- // Calculate Charging Duration // --
DECLARE curOffender CURSOR FAST_FORWARD FOR
SELECT DISTINCT OffenderID FROM @BatteryEvents 
OPEN curOffender
  FETCH NEXT FROM curOffender INTO @Offender
    WHILE (@@FETCH_STATUS = 0)
      BEGIN
        DECLARE curCharging CURSOR FAST_FORWARD FOR
        SELECT EventID, EventTime FROM @BatteryEvents WHERE OffenderID = @Offender ORDER BY EventTime ASC
        OPEN curCharging
          FETCH NEXT FROM curCharging INTO @EvtID, @Time
            WHILE (@@FETCH_STATUS = 0)
              BEGIN

                -- // Battery Charging Event // --
                IF (@EvtID = 217 AND @ChargeStartTime IS NULL)
                  SET @ChargeStartTime = @Time

                -- // Battery Charged Event // --
                IF (@EvtID = 218 AND @ChargeStartTime IS NOT NULL)
                  BEGIN
                    SET @Duration = CONVERT(INT,DATEDIFF(mi, @ChargeStartTime, @Time))
                    UPDATE @BatteryEvents
                      SET [ChargeStart] = @ChargeStartTime,
                          [ChargeDuration] = @Duration
                      WHERE [EventTime] = @Time 
                        AND [EventID] = @EvtID
                    SET @ChargeStartTime = NULL
                  END
                FETCH NEXT FROM curCharging INTO @EvtID, @Time
              END 

          -- // Handle case of no Battery Charged Event // --
          IF (@ChargeStartTime IS NOT NULL AND @Duration IS NULL)
            BEGIN
              SET @Duration = CONVERT(INT,DATEDIFF(mi, @ChargeStartTime, @Time))
                UPDATE @BatteryEvents
                  SET [ChargeStart] = @ChargeStartTime,
                      [ChargeDuration] = @Duration
                  WHERE [EventTime] = @Time
                    AND [EventID] = @EvtID
            END
          CLOSE curCharging               -- Clean up this Offenders event cursor
          DEALLOCATE curCharging 
          SET @ChargeStartTime = NULL     -- Clear Vars for next Offender
          SET @Duration = NULL   
          FETCH NEXT FROM curOffender INTO @Offender
      END
CLOSE curOffender                         -- Clean up offender cursor
DEALLOCATE curOffender

-- // Get Final Results // --
SELECT Agency,
       Officer,
       Offender,
       SerialNumber,
       ChargeStart,
       EventTime AS ChargeEnd,
       ChargeDuration,
       @RunDate AS [RunDate],
       CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
       CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]  
FROM @BatteryEvents 
WHERE ChargeStart IS NOT NULL 
  AND ChargeDuration IS NOT NULL
ORDER BY Offender ASC,
         ChargeStart ASC
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_DeviceCharging] TO db_dml;
GO
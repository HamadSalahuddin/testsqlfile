USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Agn_RollCall]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Agn_RollCall]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Agn_RollCall.sql
 * Created On: 11/29/2012
 * Created By: R.Cole
 * Task #:     3793
 * Purpose:    Get data for automated roll call              
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Agn_RollCall] (
  @AgencyID INT = -1,
  @RollCall DATETIME,
  @GracePeriod INT,
  @TimeZoneID INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--*****************************************
/* *** Dev Test *** 
DECLARE @RollCall DATETIME,
        @GracePeriod INT,
        @AgencyID INT,
        @TimeZoneID INT

SET @RollCall = '2012-12-06 11:43:00.000'--GETDATE()
SET @GracePeriod = 60
SET @AgencyID = 1 -- SA 1, laguna 21 on Islas
SET @TimeZoneID = 8
*/
--****************************************

-- // Set up Variables // --
DECLARE @HighWaterMark DATETIME,
        @StartDate DATETIME,
        @EndDate DATETIME,
        @UTCOffset INT

-- // Setup Dates // --
SET @UTCOffset = dbo.fnGetUTCOffsetByTimeZoneID(@TimeZoneID, @RollCall)                                          -- Get offset for specified timezone, accounts for DST
SET @HighWaterMark = (SELECT RTM_HighTime FROM RTM_TableState WHERE RTM_TableName LIKE 'BucketMover_Bucket1')    -- Handle historical queries
SET @StartDate = DATEADD(MI, -@GracePeriod, @RollCall)
SET @EndDate = DATEADD(MI, @GracePeriod, @RollCall)

-- ****************************************
/* *** Dev Test *** 
SELECT @HighWaterMark AS HWM,
       @RollCall AS RollCall,
       @GracePeriod AS Grace,
       @StartDate AS ST,
       @EndDate AS ET,
       @UTCOffset AS Offset
*/
-- ****************************************
   
-- // Main Query // --
IF @AgencyID = -1
  -- // Get data for all agencies // --
  BEGIN
    -- // Check the Date range to see which bucket we need // --
    IF ((@StartDate > DATEADD(MI, @UTCOffset, @HighWaterMark)) AND (@EndDate > DATEADD(MI, @UTCOffset, @HighWatermark)))  
      -- // Date range is entirely in Bucket1 // --
      BEGIN
        SELECT --evt.EventPrimaryID,
               agn.AgencyID,
               agn.Agency AS 'Camp',
               evt.OffenderID,
               ofn.LastName + ', ' +  ofn.FirstName AS 'OffenderName',
               evt.DeviceID AS 'TrackerID',  
               dp.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt.EventDateTime) AS 'EventDateTime',  
               evt.EventID AS 'EventTypeID', 
		           evt.EventName,
               evt.Latitude,
               evt.Longitude,
               evt.GpsValid,
               evt.GpsValidSatellites,
               Officer.FirstName + ' ' + Officer.LastName AS 'Division'
        FROM rprtEventsBucket1 (NOLOCK) evt
          INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID  
          INNER JOIN Agency (NOLOCK) agn ON ofn.AgencyID = agn.AgencyID
          INNER JOIN Offender_Officer oo ON ofn.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON evt.DeviceID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012' -- S/N                              
	      WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
          AND agn.AgencyID = 1
--          AND agn.AgencyID IN (20,21,22,23,24,26,27,28,30)                   -- Islas Agencies
      END
    ELSE IF ((@StartDate < DATEADD(MI, @UTCOffset, @HighWaterMark)) AND (@EndDate < DATEADD(MI, @UTCOffset, @HighWaterMark)))
      -- // Date range is entirely in Bucket2 // --
      BEGIN
        SELECT --evt2.EventPrimaryID,
               agn2.AgencyID,
               agn2.Agency AS 'Camp',
               evt2.OffenderID,
               ofn2.LastName + ', ' +  ofn2.FirstName AS 'OffenderName',
               evt2.DeviceID AS 'TrackerID',  
               dp2.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt2.EventDateTime) AS 'EventDateTime',  
               evt2.EventID AS 'EventTypeID', 
		           evt2.EventName,
               evt2.Latitude,
               evt2.Longitude,
               evt2.GpsValid,
               evt2.GpsValidSatellites,
               o2.FirstName + ' ' + o2.LastName AS 'Division'
        FROM rprtEventsBucket2 (NOLOCK) evt2
          INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID  
          INNER JOIN Agency (NOLOCK) agn2 ON ofn2.AgencyID = agn2.AgencyID
          INNER JOIN Offender_Officer oo2 ON ofn2.OffenderID = oo2.OffenderID
          INNER JOIN Officer o2 ON oo2.OfficerID = o2.OfficerID
          INNER JOIN Gateway.dbo.Devices dev2 ON evt2.DeviceID = dev2.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp2 ON dev2.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8012' -- S/N
	      WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
          AND agn2.AgencyID = 1
--          AND agn2.AgencyID IN (20,21,22,23,24,26,27,28,30)                   -- Islas Agencies
      END
    ELSE
      -- // Date range spans both buckets // --
      BEGIN
        SELECT --evt.EventPrimaryID,
               agn.AgencyID,
               agn.Agency AS 'Camp',
               evt.OffenderID,
               ofn.LastName + ', ' +  ofn.FirstName AS 'OffenderName',
               evt.DeviceID AS 'TrackerID',  
               dp.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt.EventDateTime) AS 'EventDateTime',  
               evt.EventID AS 'EvenTypeID', 
		           evt.EventName,
               evt.Latitude,
               evt.Longitude,
               evt.GpsValid,
               evt.GpsValidSatellites,
               Officer.FirstName + ' ' + Officer.LastName AS 'Division'        
        FROM rprtEventsBucket1 (NOLOCK) evt
          INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID  
          INNER JOIN Agency (NOLOCK) agn ON ofn.AgencyID = agn.AgencyID
          INNER JOIN Offender_Officer oo ON ofn.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON evt.DeviceID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012' -- S/N                    
	      WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
          AND agn.AgencyID = 1
--          AND agn.AgencyID IN (20,21,22,23,24,26,27,28,30)                   -- Islas Agencies

        UNION ALL

        SELECT --evt2.EventPrimaryID,
               agn2.AgencyID,
               agn2.Agency AS 'Camp',
               evt2.OffenderID,
               ofn2.LastName + ', ' +  ofn2.FirstName AS 'OffenderName',
               evt2.DeviceID AS 'TrackerID',  
               dp2.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt2.EventDateTime) AS 'EventDateTime',  
               evt2.EventID AS 'EventTypeID', 
		           evt2.EventName,
               evt2.Latitude,
               evt2.Longitude,
               evt2.GpsValid,
               evt2.GpsValidSatellites,
               o2.FirstName + ' ' + o2.LastName AS 'Division'
        FROM rprtEventsBucket2 (NOLOCK) evt2
          INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID  
          INNER JOIN Agency (NOLOCK) agn2 ON ofn2.AgencyID = agn2.AgencyID
          INNER JOIN Offender_Officer oo2 ON ofn2.OffenderID = oo2.OffenderID
          INNER JOIN Officer o2 ON oo2.OfficerID = o2.OfficerID
          INNER JOIN Gateway.dbo.Devices dev2 ON evt2.DeviceID = dev2.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp2 ON dev2.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8012' -- S/N
	      WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
          AND agn2.AgencyID = 1
--          AND agn2.AgencyID IN (20,21,22,23,24,26,27,28,30)                   -- Islas Agencies
      END
  END
ELSE
  -- // Get data for a single agency // --
  BEGIN
    -- // Check the Date range to see which bucket we need // --
    IF ((@StartDate > @HighWaterMark) AND (@EndDate > @HighWaterMark))
      -- // Date range is entirely in Bucket1 // --
      BEGIN
        SELECT --evt.EventPrimaryID,
               agn.AgencyID,
               agn.Agency AS 'Camp',
               evt.OffenderID,
               ofn.LastName + ', ' +  ofn.FirstName AS 'OffenderName',
               evt.DeviceID AS 'TrackerID',  
               dp.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt.EventDateTime) AS 'EventDateTime',  
               evt.EventID AS 'EventTypeID', 
		           evt.EventName,
               evt.Latitude,
               evt.Longitude,
               evt.GpsValid,
               evt.GpsValidSatellites,
               Officer.FirstName + ' ' + Officer.LastName AS 'Division'
        FROM rprtEventsBucket1 (NOLOCK) evt
          INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID  
          INNER JOIN Agency (NOLOCK) agn ON ofn.AgencyID = agn.AgencyID
          INNER JOIN Offender_Officer oo ON ofn.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON evt.DeviceID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012' -- S/N                    
	    WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
        AND agn.AgencyID = @AgencyID
      END
    ELSE IF ((@StartDate < DATEADD(MI, @UTCOffset, @HighWaterMark)) AND (@EndDate < DATEADD(MI, @UTCOffset, @HighWaterMark)))
      -- // Date range is entirely in Bucket2 // --
      BEGIN
        SELECT --evt2.EventPrimaryID,
               agn2.AgencyID,
               agn2.Agency AS 'Camp',
               evt2.OffenderID,
               ofn2.LastName + ', ' +  ofn2.FirstName AS 'OffenderName',
               evt2.DeviceID AS 'TrackerID',  
               dp2.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt2.EventDateTime) AS 'EventDateTime',  
               evt2.EventID AS 'EventTypeID', 
		           evt2.EventName,
               evt2.Latitude,
               evt2.Longitude,
               evt2.GpsValid,
               evt2.GpsValidSatellites,
               o2.FirstName + ' ' + o2.LastName AS 'Division'
        FROM rprtEventsBucket2 (NOLOCK) evt2
          INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID  
          INNER JOIN Agency (NOLOCK) agn2 ON ofn2.AgencyID = agn2.AgencyID
          INNER JOIN Offender_Officer oo2 ON ofn2.OffenderID = oo2.OffenderID
          INNER JOIN Officer o2 ON oo2.OfficerID = o2.OfficerID
          INNER JOIN Gateway.dbo.Devices dev2 ON evt2.DeviceID = dev2.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp2 ON dev2.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8012' -- S/N
	    WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
        AND agn2.AgencyID = @AgencyID
      END
    ELSE
      -- // Date range spans both buckets // --
      BEGIN
        SELECT --evt.EventPrimaryID,
               agn.AgencyID,
               agn.Agency AS 'Camp',
               evt.OffenderID,
               ofn.LastName + ', ' +  ofn.FirstName AS 'OffenderName',
               evt.DeviceID AS 'TrackerID',  
               dp.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt.EventDateTime) AS 'EventDateTime',  
               evt.EventID AS 'EventTypeID', 
		           evt.EventName,
               evt.Latitude,
               evt.Longitude,
               evt.GpsValid,
               evt.GpsValidSatellites,
               Officer.FirstName + ' ' + Officer.LastName AS 'Division'
        FROM rprtEventsBucket1 (NOLOCK) evt
          INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID  
          INNER JOIN Agency (NOLOCK) agn ON ofn.AgencyID = agn.AgencyID
          INNER JOIN Offender_Officer oo ON ofn.OffenderID = oo.OffenderID
          INNER JOIN Officer ON oo.OfficerID = Officer.OfficerID
          INNER JOIN Gateway.dbo.Devices dev ON evt.DeviceID = dev.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp ON dev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012' -- S/N                    
	      WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
          AND agn.AgencyID = @AgencyID

        UNION ALL

        SELECT --evt2.EventPrimaryID,
               agn2.AgencyID,
               agn2.Agency AS 'Camp',
               evt2.OffenderID,
               ofn2.LastName + ', ' +  ofn2.FirstName AS 'OffenderName',
               evt2.DeviceID AS 'TrackerID',  
               dp2.PropertyValue AS 'DeviceSN',
               DATEADD(MI, @UTCOffset, evt2.EventDateTime) AS 'EventDateTime',  
               evt2.EventID AS 'EventTypeID', 
		           evt2.EventName,
               evt2.Latitude,
               evt2.Longitude,
               evt2.GpsValid,
               evt2.GpsValidSatellites,
               o2.FirstName + ' ' + o2.LastName AS 'Division'
        FROM rprtEventsBucket2 (NOLOCK) evt2
          INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID  
          INNER JOIN Agency (NOLOCK) agn2 ON ofn2.AgencyID = agn2.AgencyID
          INNER JOIN Offender_Officer oo2 ON ofn2.OffenderID = oo2.OffenderID
          INNER JOIN Officer o2 ON oo2.OfficerID = o2.OfficerID
          INNER JOIN Gateway.dbo.Devices dev2 ON evt2.DeviceID = dev2.DeviceID
          INNER JOIN Gateway.dbo.DeviceProperties dp2 ON dev2.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8012' -- S/N
	      WHERE (DATEADD(MI, @UTCOffset, EventDateTime) BETWEEN @StartDate AND @EndDate)
          AND agn2.AgencyID = @AgencyID
      END
  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Agn_RollCall] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Otd_v1674FirmwareRollout]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Otd_v1674FirmwareRollout]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Otd_v1674FirmwareRollout.sql
 * Created On: 10/11/2012         
 * Created By: R.Cole
 * Task #:     #3712
 * Purpose:    Assist with the rollout of v1674 Firmware               
 *
 * Modified By: R.Cole - 12/06/2012: Added new field
 *              R.Cole - 01/23/2013: Per 3889, Added two new fields
 *              R.Cole - 05/15/2013: Per 4084, Added four new fields
 *              Per 3889, Added two fields.
 *              R.Cole - 05/28/2013: Per 4084, Added Agency State.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Otd_v1674FirmwareRollout] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @UTCOffset INT
SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- TimeZoneID 8 = MountainTime
   
-- // Main Query // --
SELECT DISTINCT gwDevices.DeviceID AS 'Device GID',
        dp.PropertyValue AS 'Serial Number',
        Agency.Agency,
        st.[State] AS 'Agency State',
       (CASE WHEN gwDevices.DeviceID IN (SELECT DISTINCT ota.TrackerID
                                    		 FROM Trackerpal.dbo.OffenderTrackerActivation ota
		                                     WHERE ota.DeactivateDate IS NULL) THEN 'Active' ELSE 'Inactive' END) AS 'OnAnkle Status',
        Gateway.dbo.HexToSmallInt(dp13.PropertyValue) AS 'Dirty Bit',
        Gateway.dbo.HexToSmallInt(dp1.PropertyValue) AS 'Firmware Rev',
        dp2.PropertyValue AS 'Hardware Rev',
        dp19.PropertyValue AS 'Modem Firmware Rev',
        dp20.PropertyValue AS 'GPS Firmware Rev',
        dp21.PropertyValue AS 'GPS Hardware Rev',
--        Gateway.dbo.HexToSmallInt(dp20.PropertyValue) AS 'GPS Firmware Rev',
        dp3.PropertyValue AS 'ICCID',
        dp4.PropertyValue AS 'IMSI',
        dp14.PropertyValue AS 'Primary APN',
        dp15.PropertyValue AS 'Secondary APN',
        Gateway.dbo.HexToSmallInt(dp16.PropertyValue) AS 'Tracking Interval',
        Gateway.dbo.HexToSmallInt(dp17.PropertyValue) AS 'Batch-#Events',
        Gateway.dbo.HexToSmallInt(dp18.PropertyValue) AS 'Batch-Time',
        CASE WHEN gwDevices.LastEventTime != 0 THEN DATEADD(MINUTE, @UTCOffset, dbo.ConvertLongToDate(gwDevices.LastEventTime)) 
                                               ELSE '1900-01-01 00:00:00.001' 
        END AS 'Last Report (MT)',
        CASE WHEN gwDevices.LastConfigRefreshTime !=0 THEN DATEADD(MINUTE, @UTCOffset, dbo.ConvertLongToDate(gwDevices.LastConfigRefreshTime))
                                                  ELSE '1900-01-01 00:00:00.001'
        END AS 'Last Config Refresh (MT)',
        Gateway.dbo.HexToSmallInt(dp5.PropertyValue) AS 'Parallel Battery - Batt Low',
        Gateway.dbo.HexToSmallInt(dp6.PropertyValue) AS 'Parallel Battery - Batt Crit',
        Gateway.dbo.HexToSmallInt(dp7.PropertyValue) AS 'Parallel Battery - Batt Crit Esc',
        Gateway.dbo.HexToSmallInt(dp8.PropertyValue) AS 'Parallel Battery - Batt Shutdown',
        Gateway.dbo.HexToSmallInt(dp9.PropertyValue) AS 'Series Battery - Batt Low',
        Gateway.dbo.HexToSmallInt(dp10.PropertyValue) AS 'Series Battery - Batt Crit',
        Gateway.dbo.HexToSmallInt(dp11.PropertyValue) AS 'Series Battery - Batt Crit Esc',
        Gateway.dbo.HexToSmallInt(dp12.PropertyValue) AS 'Series Battery - Batt Shutdown'
FROM Gateway.dbo.Devices gwDevices
  INNER JOIN TrackerPal.dbo.Tracker Tracker ON gwDevices.DeviceID = Tracker.TrackerID
  INNER JOIN TrackerPal.dbo.Agency ON Tracker.AgencyID = Agency.AgencyID
	INNER JOIN TrackerPal.dbo.State st ON Agency.StateID = st.StateID
  INNER JOIN Gateway.dbo.DeviceProperties dp ON gwDevices.DeviceID = dp.DeviceID AND dp.PropertyID = '8012'             -- S/N
  INNER JOIN Gateway.dbo.DeviceProperties dp1 ON gwDevices.DeviceID = dp1.DeviceID AND dp1.PropertyID = '8016'          -- Firmware Rev.
  INNER JOIN Gateway.dbo.DeviceProperties dp2 ON gwDevices.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8010'          -- Hardware Rev.
  INNER JOIN Gateway.dbo.DeviceProperties dp3 ON gwDevices.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8204'          -- ICCID
  INNER JOIN Gateway.dbo.DeviceProperties dp4 ON gwDevices.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8202'          -- IMSI
  INNER JOIN Gateway.dbo.DeviceProperties dp13 ON gwDevices.DeviceID = dp13.DeviceID AND dp13.PropertyID = '8001'       -- DirtyBit
  INNER JOIN Gateway.dbo.DeviceProperties dp14 ON gwDevices.DeviceID = dp14.DeviceID AND dp14.PropertyID = '8210'       -- PrimaryAPN
  INNER JOIN Gateway.dbo.DeviceProperties dp15 ON gwDevices.DeviceID = dp15.DeviceID AND dp15.PropertyID = '8211'       -- SecondaryAPN
  INNER JOIN Gateway.dbo.DeviceProperties dp16 ON gwDevices.DeviceID = dp16.DeviceID AND dp16.PropertyID = '8020'       -- Tracking Interval
  INNER JOIN Gateway.dbo.DeviceProperties dp19 ON gwDevices.DeviceID = dp19.DeviceID AND dp19.PropertyID = '8201'       -- Modem Firmware Ver
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp20 ON gwDevices.DeviceID = dp20.DeviceID AND dp20.PropertyID = '8145'  -- GPS Firmware Ver
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp21 ON gwDevices.DeviceID = dp21.DeviceID AND dp21.PropertyID = '8146'  -- GPS Hardware Ver
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp17 ON gwDevices.DeviceID = dp17.DeviceID AND dp17.PropertyID = '80B9'  -- Batch -#Events
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp18 ON gwDevices.DeviceID = dp18.DeviceID AND dp18.PropertyID = '80BA'  -- Batch-Time
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp5 ON gwDevices.DeviceID = dp5.DeviceID AND dp5.PropertyID = '8050'     -- Batt Low
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp6 ON gwDevices.DeviceID = dp6.DeviceID AND dp6.PropertyID = '8051'     -- Batt Crit
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp7 ON gwDevices.DeviceID = dp7.DeviceID AND dp7.PropertyID = '8049'     -- Batt Crit Esc
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp8 ON gwDevices.DeviceID = dp8.DeviceID AND dp8.PropertyID = '8048'     -- Batt Shutdown
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp9 ON gwDevices.DeviceID = dp9.DeviceID AND dp9.PropertyID = '804F'     -- S.Batt Low
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp10 ON gwDevices.DeviceID = dp10.DeviceID AND dp10.PropertyID = '804E'  -- S.Batt Crit
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp11 ON gwDevices.DeviceID = dp11.DeviceID AND dp11.PropertyID = '804D'  -- S.Batt Crit Esc
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp12 ON gwDevices.DeviceID = dp12.DeviceID AND dp12.PropertyID = '804C'  -- S.Batt Shutdown  
WHERE Tracker.Deleted = 0
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker t WHERE t.TrackerID = gwDevices.DeviceID)
	AND Tracker.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)  -- // This is not applicable for Int'l servers // --
ORDER BY Agency
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Otd_v1674FirmwareRollout] TO db_dml;
GO
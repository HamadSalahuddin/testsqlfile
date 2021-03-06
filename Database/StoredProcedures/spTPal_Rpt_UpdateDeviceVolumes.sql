USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_UpdateDeviceVolumes]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_UpdateDeviceVolumes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_UpdateDeviceVolumes.sql
 * Created On: 02/04/2013         
 * Created By: R.Cole  
 * Task #:     #3901      
 * Purpose:    Obtain daily device volume stats.              
 *
 * Modified By: R.Cole - 02/05/2013: Found and fixed a
 *              time conversion bug.
 *              R.Cole - 02/20/2013: Added code to exclude
 *              Puerto Rico agencies - They have their own
 *              version of stats.
 *              R.Cole - 3/12/2013: Found and fixed another
 *              time conversion bug.
 *              R.Cole - 07/11/2013: Fixed a bug where some
 *              devices that have never been activated were
 *              inadvertently being excluded from the results.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_UpdateDeviceVolumes] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @DataDate DATETIME,
        @ReportDate VARCHAR(10),
        @UTCOffset INT,
        @Active INT,
        @Inactive INT,
        @RMA INT,
        @Reported INT,
        @OldDataID INT

SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- TimeZoneID 8 = MountainTime
SET @DataDate = dbo.fn_DateToJustAfterMidnight(DATEADD(DD, -1, DATEADD(MI, @UTCOffset, GETDATE())))
SET @ReportDate = CONVERT(VARCHAR(10), GETDATE(), 23)
   
-- // Main Query // --
SELECT DISTINCT dp1.PropertyValue AS Device,
       (CASE WHEN Tracker.TrackerID IN (SELECT DISTINCT	ota.TrackerID
                                    		FROM Trackerpal.dbo.OffenderTrackerActivation ota
		                                    WHERE DATEADD(MI,@UTCOffset,ota.ActivateDate) < @DataDate
			                                    AND (DATEADD(MI,@UTCOffset,ota.DeactivateDate) >= @DataDate
			                                     OR ota.DeactivateDate IS NULL)) THEN 'Active' ELSE 'Inactive' END) AS Status,
       (CASE	WHEN tra.Rmaid IS NOT NULL THEN 'RMA'
		          WHEN Tracker.TrackerID IN (SELECT DISTINCT ota.TrackerID
		                                     FROM Trackerpal.dbo.OffenderTrackerActivation ota
                                     		 WHERE DATEADD(MI, @UTCOffset,ota.ActivateDate) < @DataDate
			                                     AND (DATEADD(MI, @UTCOffset,ota.DeactivateDate) >= @DataDate
			                                      OR ota.DeactivateDate IS NULL)) THEN 'Active' 
              ELSE 'Inactive' 
       END) AS SubStatus,
       (CASE	WHEN Devices.LastEventTime !=0 THEN DATEADD(MI, @UTCOffset,Trackerpal.dbo.ConvertLongToDate(Devices.LastEventTime)) ELSE 'N/A' END) AS 'LastReported (MT)' 
INTO #tmpStats
FROM Trackerpal.dbo.Tracker
  INNER JOIN TrackerPal.dbo.Agency ON Tracker.AgencyID = Agency.AgencyID
	INNER JOIN Gateway.dbo.DeviceProperties dp1 ON Tracker.TrackerID = dp1.DeviceID AND dp1.PropertyID = '8012'       --S/N
	LEFT OUTER JOIN Gateway.dbo.Devices ON Tracker.TrackerID = devices.DeviceID
	LEFT OUTER JOIN Trackerpal.dbo.TrackerRma tra ON tra.TrackerID = Tracker.TrackerID AND tra.RemovedDate IS NULL
  LEFT OUTER JOIN TrackerPal.dbo.OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
              AND ota.TrackerActivationID = (SELECT MAX(TrackerActivationID) FROM TrackerPal.dbo.OffenderTrackerActivation ta WHERE ta.TrackerID = ota.TrackerID)
WHERE DATEADD(MI, @UTCOffset, Tracker.CreatedDate) < @DataDate                           
	AND (DATEADD(MI, @UTCOffset, Tracker.ModifiedDate) >= @DataDate OR Tracker.Deleted = 0)    
  AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)                           -- US Production ONLY
  AND Agency.AgencyID NOT IN (985,1499,1508,1535,1576,1577,1578,1579,1580,1581,1582,1583,1584,1585,1587)  -- US Production ONLY
	AND dp1.PropertyValue NOT LIKE '0'
--  AND ota.TrackerActivationID = (SELECT MAX(TrackerActivationID) FROM TrackerPal.dbo.OffenderTrackerActivation ta WHERE ta.TrackerID = ota.TrackerID)
ORDER BY dp1.PropertyValue

-- // Calculate the Results // --
SET @Active = (SELECT COUNT(DISTINCT Device) FROM #tmpStats WHERE Status LIKE 'Active' AND SubStatus LIKE 'Active')
SET @Inactive = (SELECT COUNT(DISTINCT Device) FROM #tmpStats WHERE Status LIKE 'Inactive' AND SubStatus LIKE 'Inactive')
SET @RMA = (SELECT COUNT(DISTINCT Device) FROM #tmpStats WHERE Status LIKE 'Inactive' AND SubStatus LIKE 'RMA')
SET @Reported = (SELECT COUNT(DISTINCT Device) FROM #tmpStats WHERE [LastReported (MT)] > DATEADD(hh, -24, DATEADD(MI, @UTCOffset, GETDATE())) AND [LastReported (MT)] NOT LIKE 'N/A')

-- // Insert data into storage // --
INSERT INTO [dbo].[DeviceVolumes] (
  [ReportDate],
  [DataDate],
  [Active],
  [Inactive],
  [RMA],
  [Reported]
)
VALUES (
  @ReportDate,
  @DataDate,
  @Active,
  @Inactive,
  @RMA,
  @Reported
)

SET @OldDataID = @@IDENTITY

-- // Clean Up // --
DROP TABLE #tmpStats

-- // Disable previous day's data // --
IF (@OldDataID > 1)
  BEGIN
    UPDATE [dbo].[DeviceVolumes]
      SET CurrentRecord = 0
      WHERE DeviceVolumeID = @OldDataID - 1
  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_UpdateDeviceVolumes] TO db_dml;
GO
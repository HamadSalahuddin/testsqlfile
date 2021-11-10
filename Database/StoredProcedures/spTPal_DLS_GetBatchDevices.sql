USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_DLS_GetBatchDevices]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_DLS_GetBatchDevices]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_DLS_GetBatchDevices.sql
 * Created On: 10/12/2010         
 * Created By: R.Cole  
 * Task #:     #1397      
 * Purpose:    Populate the DSBatchDevice table with devices
 *             that need to be updated for the given BatchID
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_DLS_GetBatchDevices] (
  @BatchID INT
) 
AS
SET NOCOUNT ON;

-- // Declare Var's // --
DECLARE @RowSelected BIT,
        @DBModified BIT,
        @Queued BIT,
        @Ack SMALLINT      

-- // Set Default Values // --
SET @RowSelected = 1
SET @DBModified = 0
SET @Queued = 0
SET @Ack = 0

-- // Get OTD's that need to be updated // --
SELECT * INTO #tmpDevices FROM (  

  -- // Get OTD's with GeoRules // --
  SELECT DISTINCT ota.TrackerID,
         Tracker.TrackerName,
         'Type' = (Select 0),         
			   s.State
  FROM Offender o
	  INNER JOIN State s ON o.HomeStateOrProvinceID = s.StateID
	  INNER JOIN OffenderTrackerActivation ota ON ota.OffenderID = o.OffenderID
	  INNER JOIN Tracker ON Tracker.TrackerID = ota.TrackerID
	  INNER JOIN GeoRule_Offender gro ON o.OffenderID = gro.OffenderID
	  INNER JOIN GeoRule gr ON gr.GeoRuleID = gro.GeoRuleID
	  INNER JOIN GeoRuleSchedule grs ON grs.GeoRuleScheduleID = gr.GeoRuleScheduleID	    
  WHERE ota.DeActivateDate IS NULL          -- Exclude DeActivated Devices
    AND o.Deleted = 0                       -- Exclude Archived Offenders
	  AND grs.AlwaysOn = 0                    -- Exclude Always On
	  AND s.StateID <> 4		                  -- Exclude Arizona OTD's  

  UNION ALL

  -- // Get OTD's with eArrest Rules // --
  SELECT DISTINCT ota.TrackerID,
         Tracker.TrackerName,
         'Type' = (SELECT 1),
		     s.State
  FROM Offender o 
	  INNER JOIN State s ON o.HomeStateOrProvinceID = s.StateID
	  INNER JOIN OffenderTrackerActivation ota ON ota.OffenderID = o.OffenderID 
	  INNER JOIN Tracker ON Tracker.TrackerID = ota.TrackerID	  
	  INNER JOIN BeaconOffender bo ON o.OffenderID = bo.OffenderID
	  INNER JOIN ERule er ON er.BeaconID = bo.BeaconID
	  INNER JOIN [Rule] r ON r.ID = er.RuleID
	  INNER JOIN Schedule sch ON r.ID = sch.RuleID
	  INNER JOIN TrackerAssignment ta ON ta.offenderID = o.offenderid and ta.trackerid = ota.Trackerid
  WHERE ota.DeActivateDate is null          -- Exclude DeActivated Devices
		AND o.Deleted = 0                       -- Exclude Archived Offenders
		AND sch.AlwaysOn = 0                    -- Exclude Always On
		AND s.StateID <> 4                      -- Exclude Arizona OTD's
) AS tmp

-- // Populate the DSBatchDevice Table // --
INSERT INTO dbo.DSBatchDevice (
    [BatchID], 
    [Type], 
    [RowSelected], 
    [DeviceID], 
    [DeviceSerialNumber], 
    [CountryState], 
    [DBModified], 
    [Queued], 
    [Ack]
)
  SELECT @BatchID,
         [Type],
         @RowSelected, 
         TrackerID,
         TrackerName,
         [State],
         @DBModified,
         @Queued,
         @Ack
  FROM #tmpDevices

-- // Perform Clean Up // --
DROP TABLE #tmpDevices
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_DLS_GetBatchDevices] TO db_dml;
GO
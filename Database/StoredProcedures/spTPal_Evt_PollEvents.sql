USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Evt_PollEvents]    Script Date: 01/15/2016 07:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   spTPal_Evt_PollEvents.sql
 * Created On: 12/20/2010
 * Created By: R.Cole  
 * Task #:     #1729       
 * Purpose:    Combine the 'Polling/HighWaterMark' query with 
 *             the 'light' device status object query.  This 
 *             will address the Connection Pool issue.               
 *
 * Modified By: R.Cole - 04/15/2011: Revised the handling of 
 *                the HighWaterMark.  #2198
 *              R.Cole - 9/06/2011: Forced subquery to use
 *                the correct Bucket1 index. Significant 
 *                performance gain.
				D. Riding 10/22/14	Use fnTPal_GetBatteryEmptyFullLimits to get battery Empty and Full values.  
									Changes marked with DR102214
 *				S.Khaliq 15 Jan 2016 replaced rprtEventsBucket1.NoteCount with NoteCount sub query  Task#8142
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Evt_PollEvents]
AS
BEGIN
--  SET NOCOUNT ON;
  
  DECLARE @HighWaterMark BIGINT,
          @NewMark BIGINT
          --@Now DATETIME,  
          --@HighWaterMark DATETIME

  -- // Get the HighWater Mark  // --
--  SET @Now = GETDATE()
--  SET @HighWaterMark = (SELECT RTM_HighTime FROM RTM_TableState WHERE RTM_TableName LIKE 'rprtEventsBucket1')
  SET @HighWaterMark = (SELECT RTM_HighID FROM RTM_TableState WHERE RTM_TableName LIKE 'rprtEventsBucket1')
    
  -- // Get the latest set of Events // --
  SELECT rprtEventsBucket1.EventPrimaryID,
         rprtEventsBucket1.DeviceID,
         EventTime,
         EventDateTime,
         ReceivedTime,
         TrackerNumber,
         EventID,    
         EventParameter,
         AlarmType,
         AlarmAssignmentStatusID,
         AlarmAssignmentStatusName,
         EventName,
         Longitude,
         Latitude,
         [Address],
         OffenderID,
         ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = rprtEventsBucket1.AlarmID ) + (SELECT COUNT(EventNoteID) 
																   FROM EventNote (NOLOCK)
																   WHERE DeviceID = rprtEventsBucket1.DeviceID 
																	 AND EventTime = rprtEventsBucket1.EventTime 
																	 AND EventID = rprtEventsBucket1.EventID)
	           ) AS 'NoteCount'	,
         AlarmID,
         GpsValid,
         GpsValidSatellites,
         GeoRule,
         SO,
         OPR,
         EventTypeGroupID,
         OfficerID,
         AgencyID,
         AcceptedDate,
         AcceptedBy,
         ActivateDate,
         DeactivateDate,
         EventQueueID,
         OffenderName,
         OffenderDeleted--,
        -- ISNULL((SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties (NOLOCK) dp WHERE dp.DeviceID = rprtEventsBucket1.DeviceID AND PropertyID = '8017'),0) AS 'DeviceType'  --DR102214 
  INTO #tmpEvents 
--  FROM rprtEventsBucket1 (NOLOCK) b1
  FROM rprtEventsBucket1 WITH (INDEX([PK__rprtEventBucket1__57BDDBAA])) --b1 --(NOLOCK) b1
  WHERE EventPrimaryID > @HighWaterMark
       --EventDateTime > @HighWaterMark AND EventDateTime <= @Now     

  -- // Get New HighWaterMark //  --
  SET @NewMark = (SELECT ISNULL(MAX(EventPrimaryID),@HighWaterMark) FROM #tmpEvents)
 
  -- // Clear the Storage Table // --
  DELETE FROM PolledEvents
  
  -- // Populate the PolledEvents Table // --
  INSERT INTO PolledEvents (
    EventPrimaryID,
    DeviceID,
    EventTime,
    EventDateTime,
    ReceivedTime,
    TrackerNumber,
    EventID,    
    EventParameter,
    AlarmType,
    AlarmAssignmentStatusID,
    AlarmAssignmentStatusName,
    EventName,
    Longitude,
    Latitude,
    [Address],
    OffenderID,
    NoteCount,
    AlarmID,
    GpsValid,
    GpsValidSatellites,
    GeoRule,
    SO,
    OPR,
    EventTypeGroupID,
    OfficerID,
    AgencyID,
    AcceptedDate,
    AcceptedBy,
    ActivateDate,
    DeactivateDate,
    EventQueueID,
    OffenderName,
    OffenderDeleted,
    [Status],
    InternalBatteryVoltage,
    IntBatteryFullVoltage,
    IntBatteryEmptyVoltage
  )
  SELECT Bucket1.EventPrimaryID,
         Bucket1.DeviceID,
         Bucket1.EventTime,
         Bucket1.EventDateTime,
         Bucket1.ReceivedTime,
         Bucket1.TrackerNumber,
         Bucket1.EventID,    
         Bucket1.EventParameter,
         Bucket1.AlarmType,
         Bucket1.AlarmAssignmentStatusID,
         Bucket1.AlarmAssignmentStatusName,
         Bucket1.EventName,
         Bucket1.Longitude,
         Bucket1.Latitude,
         Bucket1.[Address],
         Bucket1.OffenderID,
         Bucket1.NoteCount,
         Bucket1.AlarmID,
         Bucket1.GpsValid,
         Bucket1.GpsValidSatellites,
         Bucket1.GeoRule,
         Bucket1.SO,
         Bucket1.OPR,
         Bucket1.EventTypeGroupID,
         Bucket1.OfficerID,
         Bucket1.AgencyID,
         Bucket1.AcceptedDate,
         Bucket1.AcceptedBy,
         Bucket1.ActivateDate,
         Bucket1.DeactivateDate,
         Bucket1.EventQueueID,
         Bucket1.OffenderName,
         Bucket1.OffenderDeleted,
         gwEvents.[Status],  
	       gwEvents.InternalBatteryVoltage,
		   (SELECT ISNULL(IntBatteryFullVoltage,0) FROM Gateway.dbo.fnTPal_GetBatteryEmptyFullLimits(Bucket1.DeviceID)) AS IntBatteryFullVoltage,  --DR102214
		   (SELECT ISNULL(IntBatteryEmptyVoltage,0) FROM Gateway.dbo.fnTPal_GetBatteryEmptyFullLimits(Bucket1.DeviceID)) AS IntBatteryEmptyVoltage   --DR102214
		   /*   --DR102214 
		       CASE WHEN Bucket1.DeviceType = 2 THEN 4200
	            WHEN Bucket1.DeviceType = 3 THEN 7900
	            ELSE 0
	       END AS 'IntBatteryFullVoltage',	       
         CASE WHEN Bucket1.DeviceType = 2 THEN (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties (NOLOCK) dp1 WHERE dp1.DeviceID = Bucket1.DeviceID AND PropertyID = '8048')
              WHEN Bucket1.DeviceType = 3 THEN (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties (NOLOCK) dp2 WHERE dp2.DeviceID = Bucket1.DeviceID AND PropertyID = '804C')
              ELSE 0
         END AS 'IntBatteryEmptyVoltage'    
		 */          
  FROM #tmpEvents Bucket1
	  INNER JOIN Gateway.dbo.Events (NOLOCK) gwEvents ON Bucket1.DeviceID = gwEvents.DeviceID
	         AND Bucket1.EventID = gwEvents.EventID
	         AND Bucket1.EventTime = gwEvents.EventTime	         
	  LEFT JOIN Gateway.dbo.Devices (NOLOCK) gwDevices ON Bucket1.DeviceID = gwDevices.DeviceID  
--  WHERE Bucket1.EventDateTime > @HighWaterMark AND Bucket1.EventDateTime <= @Now  --Redundant, temp table already filtered to these times

  -- // Update the HighWaterMark // --
  UPDATE RTM_TableState
    SET RTM_HighID = @NewMark
--    SET RTM_HighTime = @Now
    WHERE RTM_TableName LIKE 'rprtEventsBucket1'
  
  -- // Clean Up // --
  DROP TABLE #tmpEvents  
END


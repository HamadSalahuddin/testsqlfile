USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Evt_GetPolledEvents]    Script Date: 01/08/2016 12:40:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Evt_GetPolledEvents.sql
 * Created On: 12/20/2010         
 * Created By: R.Cole  
 * Task #:     Redmine #      
 * Purpose:    Get the Polled Events corresponding to the passed
 *             in DeviceID's.               
 *
 * Modified By: Name - DateTime
 *				SABBASI - 3/14/2015: Added event parameter field in the result set. Task #5083.
 *              S.Khaliq - 7 Jan 2016 -- added inner join for event type and added Isprivate column in select statement Task # 9414

 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Evt_GetPolledEvents] (
    @DeviceIDs VARCHAR(MAX)
) 
AS
--SET NOCOUNT ON;
BEGIN
  
  --Extract OffenderIDs into a temp table
  SELECT [number]
  INTO #tmpDeviceIDs
  FROM GetTableFromListId(@DeviceIDs)

  CREATE CLUSTERED INDEX #xpktmpDevice ON #tmpDeviceIDs(number)
   
  -- // Main Query // --
  SELECT EventPrimaryID,
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
		 EventParameter,
         Longitude,
         Latitude,
         [Address],
         OffenderID,
         NoteCount,
         AlarmID,
         GpsValid,
         GpsValidSatellites,
         GeoRule,
         pe.SO,
         pe.OPR,
         pe.EventTypeGroupID,
         typ.IsPrivate,
         OfficerID,
         AgencyID,
         AcceptedDate,
         AcceptedBy,
         DeactivateDate,
         EventQueueID,
         OffenderName,
         OffenderDeleted,
         [Status],
         InternalBatteryVoltage,
         IntBatteryFullVoltage,
         IntBatteryEmptyVoltage
  FROM PolledEvents (NOLOCK) pe
  INNER JOIN EventType typ ON pe.EventID=typ.EventTypeID
    INNER JOIN #tmpDeviceIDs tDevice ON pe.DeviceID = tDevice.number
END

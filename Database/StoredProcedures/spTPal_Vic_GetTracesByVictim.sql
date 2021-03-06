USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_GetTracesByVictim]    Script Date: 04/12/2016 10:50:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Vic_GetTracesByVictim.sql
 * Created On: 22-Feb-2013
 * Created By: SABBASI
 * Task #:     #3849
 * Purpose:    This procedure gets list of all event traces between given dates for
 *             given Victim.               
 *
 * Modified By: R.Cole - 02/22/2013: Revised to work with new
 *              Victim data model.
 *             :SABBADI - 02/23/2013 : Changed EventID to VictimEventID, EventType.EventName, to EventType.LongName AS EventName,
 *              and VictimEvents.EventID to VictimEvents.EventTypeID AS EventID
 *              as VictimEvents table is changed. Changed some fore fields to match alarm result set.
 *             :SABBASI - 02/26/2013 : Set GpsValid and GpsValidSatellites  fields default value to 
 *             1 rather than NULL.
 *				SABBASI - 05/22/2014; Task #6089 ; Added Victim.Deleted check to filter out delete victims.
 *				SABBASI - 06/03/2014; Task #6343; Referred Address field from VictimEvents table.
 *				SABBASI - 06/10/2014; Support #6395; Retrieved GpsValid and GpsValidSatellites from VictimEvents table instead of defaulting them to 1.
 *        RCole - 6/26/2015: Added code to link VictimEvents to an Offender for #8393 (new code is commented out)
 *				SABBASI - 06/30/2014; Bug #8393; Added a condition to filter records by VictimDEvice_Tracker Created date.
 *              S.Khaliq - 7 Jan 2016 -- added inner join for event type and added Isprivate column in select statement Task # 9414
* ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Vic_GetTracesByVictim] (
	@VictimIDs VARCHAR(MAX),
	@StartDate DATETIME,
	@EndDate DATETIME
)	 
AS
BEGIN
 SET NOCOUNT ON;

  -- // Extract OffenderIDs into a temp table // --
  SELECT [number]
  INTO #tmpVictimIDs
  FROM GetTableFromListId(@VictimIDs)

  -- // Temporarily index our temp table // --
  CREATE CLUSTERED INDEX #xpktmpVictim ON #tmpVictimIDs(number)

  -- // Main Query // --
  SELECT VictimEvents.VictimEventID AS EventPrimaryID,
         Victim.VictimID AS OffenderID,                                 -- Formerly OffenderID
         Victim.LastName + ', ' +  Victim.FirstName AS 'OffenderName',  -- Formerly OffenderName
	       Victim.OfficerID,
         VictimEvents.VictimDeviceID AS DeviceID,  
         VictimEvents.DeviceIMEI AS TrackerNumber,  
         dbo.ConvertDateToLong(VictimEvents.EventDisplayTime) AS EventTime,  
         VictimEvents.EventDisplayTime AS EventDateTime,  
         VictimEvents.EventTypeID AS EventID, 
  		   EventType.AbbrevEventType AS EventName, 
         NULL AS AlarmType,                                           -- 1 = Notification, 2 = low, 3 = med, 4 = high, NULL = Nothing...duh
         EventType.IsPrivate,
         NULL AS AlarmAssignmentStatusName,
         VictimEvents.Longitude,  
         VictimEvents.Latitude,  
         VictimEvents.Address AS [Address],  
         NULL AS AlarmID,  
         VictimEvents.GpsValid,  
         VictimEvents.GpsValidSatellites,
         NULL AS GeoRule,
         0 AS 'NoteCount'
  FROM VictimEvents (NOLOCK) 
    INNER JOIN Victim (NOLOCK) ON VictimEvents.VictimDeviceID = Victim.VictimDeviceID
	  INNER JOIN #tmpVictimIDs tmpVic on Victim.VictimID = tmpVic.number
    INNER JOIN EventType ON VictimEvents.EventTypeID = EventType.EventTypeID
   	INNER JOIN VictimDevice_Tracker ON  VictimEvents.VictimDeviceID = VictimDevice_Tracker.VictimDeviceID
--    LEFT OUTER JOIN VictimDevice_Tracker vdt ON VictimEvents.VictimDeviceID = vdt.VictimDeviceID AND vdt.Deleted = 0
	WHERE ((EventDisplayTime BETWEEN @StartDate AND @EndDate) AND (VictimDevice_Tracker.CreatedDate IS NULL OR EventDisplayTime > VictimDevice_Tracker.CreatedDate)
	)
--	WHERE (EventDisplayTime BETWEEN @StartDate AND @EndDate)
--	  AND EventDisplayTime >= vdt.CreatedDate 
    AND Victim.Deleted = 0
  
--    AND VictimEvents.EventTypeID IN (271,272)
END

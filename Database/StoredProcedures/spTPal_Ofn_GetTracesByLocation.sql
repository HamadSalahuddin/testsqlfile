USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetTracesByLocation]    Script Date: 01/08/2016 12:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetTracesByLocation.sql
 * Created On: 18-Feb-2011
 * Created By: Sajid Abbasi
 * Task #:     1997
 * Purpose:    This procedure gets list of all event traces between given dates for
 *             given Offenders if that traces have been with the area of given radius.               
 *
 * Modified By: R.Cole - 2/23/2011: Changed ALTER to CREATE,
 *                added DROP IF EXISTS and GRANT stmts.
 *              R.Cole - 2/24/2011: Added <space> between 
 *                offender last, first name.
 *              R.Cole - 10/4/2011: Add code to minimize Bucket utilization.
 *               R.Cole - 10/05/2011: Added code to use highwatermark
 *                instead of date compares. 
 *              R.Cole - 10/18/2011: Fixed a bug in the 
 *                conditional logic for bucket choice
 *				SABBASI - 3/14/2015: Added event parameter field in the result set. Task #5083.
 *              S.Khaliq - 7 Jan 2016 -- added inner join for event type and added Isprivate column in select statements Task # 9414
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetTracesByLocation] (
	@OffenderIDs VARCHAR(MAX),
	@StartDate DATETIME,
	@EndDate DATETIME,
	@CenterPointlat FLOAT = 0,
	@CenterPointlong FLOAT = 0,
	@radius FLOAT = 0	
)	 
AS
BEGIN
 SET NOCOUNT ON;
 
   -- // HighWaterMark // --  
  DECLARE @HighWaterMark DATETIME
  SET @HighWaterMark = (SELECT RTM_HighTime FROM RTM_TableState WHERE RTM_TableName LIKE 'BucketMover_Bucket1')

  -- // Extract OffenderIDs into a temp table // --
  SELECT [number]
  INTO #tmpOffenderIDs
  FROM GetTableFromListId(@OffenderIDs)

  CREATE CLUSTERED INDEX #xpktmpOffender ON #tmpOffenderIDs(number)
  
  IF ((@StartDate > @HighWaterMark) AND (@EndDate > @HighWatermark))
--  IF ((@StartDate > DATEADD(MINUTE, -4320, GETDATE())) AND (@EndDate > DATEADD(MINUTE, -4320, GETDATE())))
    -- // Daterange is entirely in Bucket1 // --
    BEGIN
      SELECT evt.EventPrimaryID,
             evt.OffenderID,
	           ofn.LastName + ', ' +  ofn.FirstName AS 'OffenderName',
	           evt.OfficerID,
             evt.DeviceID,  
             evt.TrackerNumber,  
             evt.EventTime,  
             evt.EventDateTime,  
             evt.EventID, 
  		       evt.EventName, 
             evt.AlarmType,  
             evt.AlarmAssignmentStatusName,  
             evt.Longitude,  
             evt.Latitude,  
             evt.[Address],  
             evt.AlarmID,  
             evt.GpsValid,  
             evt.GpsValidSatellites,
             evt.GeoRule,
			 evt.EventParameter,
			 typ.IsPrivate,
             ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = evt.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                               FROM EventNote (NOLOCK)
	                                               WHERE DeviceID = evt.DeviceID 
	                                                 AND EventTime = evt.EventTime 
	                                                 AND EventID = evt.EventID)
	           ) AS 'NoteCount'	
      FROM rprtEventsBucket1 (NOLOCK) evt
      INNER JOIN EventType typ ON evt.EventID=typ.EventTypeID
        INNER JOIN #tmpOffenderIDs tmpoff on evt.OffenderID = tmpoff.number
	      INNER JOIN Offender (NOLOCK) ofn on evt.OffenderID = ofn.OffenderID
	    WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND ( @radius = 0 OR [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong, Latitude, Longitude) <= @radius )    
    END
  ELSE IF ((@StartDate < @HighWaterMark) AND (@EndDate < @HighWaterMark))
    -- IF @StartDate < DATEADD(MINUTE, -4320, GETDATE())
    -- // Daterange is entirely in Bucket2 // --
    BEGIN
      SELECT evt2.EventPrimaryID,
             evt2.OffenderID,
	           ofn2.LastName + ', ' +  ofn2.FirstName AS 'OffenderName',
	           evt2.OfficerID,
             evt2.DeviceID,  
             evt2.TrackerNumber,  
             evt2.EventTime,  
             evt2.EventDateTime,  
             evt2.EventID, 
  		       evt2.EventName, 
             evt2.AlarmType,  
             evt2.AlarmAssignmentStatusName,  
             evt2.Longitude,  
             evt2.Latitude,  
             evt2.[Address],  
             evt2.AlarmID,  
             evt2.GpsValid,  
             evt2.GpsValidSatellites,
             evt2.GeoRule,
			 evt2.EventParameter,
			 typ.IsPrivate,
             ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = evt2.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                               FROM EventNote (NOLOCK)
	                                               WHERE DeviceID = evt2.DeviceID 
	                                                 AND EventTime = evt2.EventTime 
	                                                 AND EventID = evt2.EventID)
	           ) AS 'NoteCount'	
      FROM rprtEventsBucket2 (NOLOCK) evt2
      INNER JOIN EventType typ ON evt2.EventID=typ.EventTypeID
	      INNER JOIN #tmpOffenderIDs tmpoff2 on evt2.OffenderID = tmpoff2.number
	      INNER JOIN Offender (NOLOCK) ofn2 on evt2.OffenderID = ofn2.OffenderID
	    WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND ( @radius = 0 OR [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong, Latitude, Longitude) <= @radius )        
    END
  ELSE
    -- // Daterange spans both Bucket1 and Bucket2 // --
    BEGIN
      SELECT evt.EventPrimaryID,
             evt.OffenderID,
	           ofn.LastName + ', ' +  ofn.FirstName AS 'OffenderName',
	           evt.OfficerID,
             evt.DeviceID,  
             evt.TrackerNumber,  
             evt.EventTime,  
             evt.EventDateTime,  
             evt.EventID, 
  		       evt.EventName, 
             evt.AlarmType,  
             evt.AlarmAssignmentStatusName,  
             evt.Longitude,  
             evt.Latitude,  
             evt.[Address],  
             evt.AlarmID,  
             evt.GpsValid,  
             evt.GpsValidSatellites,
             evt.GeoRule,
			 evt.EventParameter,
			 typ.IsPrivate,
             ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = evt.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                               FROM EventNote (NOLOCK)
	                                               WHERE DeviceID = evt.DeviceID 
	                                                 AND EventTime = evt.EventTime 
	                                                 AND EventID = evt.EventID)
	           ) AS 'NoteCount'	
      FROM rprtEventsBucket1 (NOLOCK) evt
      INNER JOIN EventType typ ON evt.EventID=typ.EventTypeID
        INNER JOIN #tmpOffenderIDs tmpoff on evt.OffenderID = tmpoff.number
	      INNER JOIN Offender (NOLOCK) ofn on evt.OffenderID = ofn.OffenderID
	    WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND ( @radius = 0 OR [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong, Latitude, Longitude) <= @radius )
      	
      UNION ALL

      SELECT evt2.EventPrimaryID,
             evt2.OffenderID,
	           ofn2.LastName + ', ' +  ofn2.FirstName AS 'OffenderName',
	           evt2.OfficerID,
             evt2.DeviceID,  
             evt2.TrackerNumber,  
             evt2.EventTime,  
             evt2.EventDateTime,  
             evt2.EventID, 
  		       evt2.EventName, 
             evt2.AlarmType,  
             evt2.AlarmAssignmentStatusName,  
             evt2.Longitude,  
             evt2.Latitude,  
             evt2.[Address],  
             evt2.AlarmID,  
             evt2.GpsValid,  
             evt2.GpsValidSatellites,
             evt2.GeoRule,
			 evt2.EventParameter,
			 typ.IsPrivate,
             ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = evt2.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                               FROM EventNote (NOLOCK)
	                                               WHERE DeviceID = evt2.DeviceID 
	                                                 AND EventTime = evt2.EventTime 
	                                                 AND EventID = evt2.EventID)
	           ) AS 'NoteCount'	
      FROM rprtEventsBucket2 (NOLOCK) evt2
      INNER JOIN EventType typ ON evt2.EventID=typ.EventTypeID
	      INNER JOIN #tmpOffenderIDs tmpoff2 on evt2.OffenderID = tmpoff2.number
	      INNER JOIN Offender (NOLOCK) ofn2 on evt2.OffenderID = ofn2.OffenderID
	    WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND ( @radius = 0 OR [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong, Latitude, Longitude) <= @radius )    
    END
END

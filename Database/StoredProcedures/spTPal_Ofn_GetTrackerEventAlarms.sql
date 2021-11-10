USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetTrackerEventAlarms]    Script Date: 01/08/2016 12:40:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetTrackerEventAlarms.sql
 * Created On: 18-Feb-2011
 * Created By: Sajid
 * Task #:     #1997
 * Purpose:    Gets events between given dates for given Offenders.               
 *
 * Modified By: R.Cole - 2/23/2011: Changed ALTER to CREATE,
 *                added DROP IF EXISTS and GRANT stmts.
 *              R.Cole - 2/24/2011: Added <space> between 
 *                offender last, first name. 
 *              R.Cole - 10/1/2011: Added code to check for
 *                one of three bucket conditions for speed optimization
 *              R.Cole - 10/4/2011: Added code to minimize bucket utilization 
 *              R.Cole - 10/05/2011: Added code to use highwatermark
 *                instead of date compares.
 *              R.Cole - 10/18/2011: Fixed a bug in the 
 *                conditional logic for bucket choice 
 *              R.Cole - 10/20/2011: Performance optimization
 *                removed some slow code.   
 *				SABBASI - 3/13/2015: Added event parameter field in the result set. Task #5083.
 *              S.Khaliq - 5 Jan 2016 -- added inner join for event type and added Isprivate column in select statements Task # 9414

 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetTrackerEventAlarms] (
	@OffenderIDs VARCHAR(MAX),
	@StartDate DATETIME,
	@EndDate DATETIME	
)	 
AS
BEGIN
  SET NOCOUNT ON;
  
   -- // HighWaterMark // --  
  DECLARE @HighWaterMark DATETIME
  SET @HighWaterMark = (SELECT RTM_HighTime FROM RTM_TableState WHERE RTM_TableName LIKE 'BucketMover_Bucket1')    

  -- //Extract OffenderIDs into a temp table // --
  SELECT [number]
  INTO #tmpOffenderIDs
  FROM GetTableFromListId(@OffenderIDs)

  -- // Index for performance // --
  CREATE CLUSTERED INDEX #xpktmpOffender ON #tmpOffenderIDs(number)
  
  -- // Check the Date range to see which bucket we need // --
  IF ((@StartDate > @HighWaterMark) AND (@EndDate > @HighWatermark))  
    -- // Date range is entirely in Bucket1 // --
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
        INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID  
	    WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND AlarmID IS NOT NULL             
    END
  ELSE IF ((@StartDate < @HighWaterMark) AND (@EndDate < @HighWaterMark))
    -- // Date range is entirely in Bucket2 // --
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
        INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID          
      WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND AlarmID IS NOT NULL                
    END
  ELSE 
    -- // Date range spans both buckets // --
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
	      INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID
      WHERE (evt.EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND evt.AlarmID IS NOT NULL
	      
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
        INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID
      WHERE (evt2.EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND evt2.AlarmID IS NOT NULL  
    END
END


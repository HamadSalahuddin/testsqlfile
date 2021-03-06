USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetTracesByOffender]    Script Date: 3/4/2021 5:32:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetTracesByOffender.sql
 * Created On: 18-Feb-2011
 * Created By: Sajid Abbasi
 * Task #:     #1997
 * Purpose:    This procedure gets list of all event traces between given dates for
 *             given Offenders.               
 *
 * Modified By: R.Cole - 2/23/2011: Changed ALTER to CREATE,
 *                added DROP IF EXISTS and GRANT stmts.
 *              R.Cole - 2/24/2011: Added <space> between 
 *                offender last, first name. 
 *              R.Cole - 10/4/2011: Added code to minimize bucket utilization
 *              R.Cole - 10/05/2011: Added code to use highwatermark
 *                instead of date compares.  
 *              R.Cole - 10/18/2011: Fixed a bug in the 
 *                conditional logic for bucket choice
 *				SABBASI - 3/13/2015: Added event parameter field in the result set. Task #5083.
 *              R.Cole - 1/6/2015: Fixed an issue
 *              where the GeoRule name was not correctly being
 *              returned.
 *              S.Khaliq - 5 Jan 2016 -- added inner join for event type and added Isprivate column in select statements Task # 9414
 *				SABBASI - 2/8/2021 - TPL-253 we need to make sure distinct events are returned in the result set.
 *			D. Riding 3/3/21 - 	#14237/TPL-426 - Use the GeoRule from the bucket tables instead of from 
 *									the GeoRule_Offender/GeoRule tables since the ZoneID changes 
 * 									for the zones every time the rules are uploaded, which was leading 
 * 									to incorrect zone names displaying. Use the GeoRule column of the bucket tables instead.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetTracesByOffender] (
	@OffenderIDs Varchar(MAX),
	@StartDate DateTime,
	@EndDate DateTime
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
      SELECT DISTINCT evt.EventPrimaryID,
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
             typ.IsPrivate,
             --CASE WHEN evt.EventTypeGroupID = 5 THEN ISNULL(gr.GeoRuleName, 'N/A') ELSE evt.GeoRule END AS GeoRule,
			CASE WHEN evt.EventTypeGroupID = 5 THEN ISNULL(evt.GeoRule, 'N/A') ELSE evt.GeoRule END AS GeoRule,
			 evt.EventParameter,
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
	  END
	ELSE IF ((@StartDate < @HighWaterMark) AND (@EndDate < @HighWaterMark))
	  -- IF @StartDate < DATEADD(MINUTE, -4320, GETDATE())
    -- // Daterange is entirely in Bucket2 // --
	  BEGIN
      SELECT DISTINCT evt2.EventPrimaryID,
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
             typ.IsPrivate,
            -- CASE WHEN evt2.EventTypeGroupID = 5 THEN ISNULL(gr2.GeoRuleName, 'N/A') ELSE evt2.GeoRule END AS GeoRule,
			CASE WHEN evt2.EventTypeGroupID = 5 THEN ISNULL(evt2.GeoRule, 'N/A') ELSE evt2.GeoRule END AS GeoRule,
			 evt2.EventParameter,
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
	  END
	ELSE
    -- // Daterange spans both Bucket1 and Bucket2 // -- 	
    BEGIN
      SELECT DISTINCT evt.EventPrimaryID,
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
             typ.IsPrivate,
             --CASE WHEN evt.EventTypeGroupID = 5 THEN ISNULL(gr.GeoRuleName,'N/A') ELSE evt.GeoRule END AS GeoRule,
             CASE WHEN evt.EventTypeGroupID = 5 THEN ISNULL(evt.GeoRule, 'N/A') ELSE evt.GeoRule END AS GeoRule,
			 evt.EventParameter,
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
    	
      UNION ALL
	 
      SELECT DISTINCT evt2.EventPrimaryID,
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
             typ.IsPrivate,
            -- CASE WHEN evt2.EventTypeGroupID = 5 THEN ISNULL(gr2.GeoRuleName, 'N/A') ELSE evt2.GeoRule END AS GeoRule,
			  CASE WHEN evt2.EventTypeGroupID = 5 THEN ISNULL(evt2.GeoRule, 'N/A') ELSE evt2.GeoRule END AS GeoRule,         
			 evt2.EventParameter,
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
    END
END

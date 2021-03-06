USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetMostRecentEvent]    Script Date: 01/08/2016 12:41:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetMostRecentEvent.sql
 * Created On: 23-Feb-2011         
 * Created By: Sajid
 * Task #:     1977
 * Purpose:    Returns most recent event for each offender in 
 *             the specified timeframe.               
 *
 * Modified By:  R.Cole - 2/24/2011: Added <space> between 
 *                offender last, first name.
 *               R.Cole - 9/07/2011: Added Date check to
 *                minimize unnecessary hits on Bucket2. 
 *               R.Cole - 10/03/2011: Added further code to
 *                minimize unnecessary bucket utilization.
 *               R.Cole - 10/05/2011: Added code to use highwatermark
 *                instead of date compares.
 *              R.Cole - 10/18/2011: Fixed a bug in the 
 *              conditional logic for bucket choice 
 *				SABBASI - 3/14/2015: Added event parameter field in the result set. Task #5083.
 *              S.Khaliq - 5 Jan 2016 -- added inner join for event type and added Isprivate column in select statements Task # 9414
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetMostRecentEvent] (
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

  -- // Extract OffenderIDs into a temp table // --
  SELECT [number]
  INTO #tmpOffenderIDs
  FROM GetTableFromListId(@OffenderIDs)
  
  -- // Create index for performance // --
  CREATE CLUSTERED INDEX #xpktmpOffender ON #tmpOffenderIDs(number)
  
  IF ((@StartDate > @HighWaterMark) AND (@EndDate > @HighWatermark))
--  IF ((@StartDate > DATEADD(minute, -4320, GETDATE())) AND (@EndDate > DATEADD(MINUTE, -4320, GETDATE())))
    -- // Date Range is entirely in Bucket1 // -- 
    BEGIN      
      SELECT OffenderID,
             MAX(EventDateTime) AS EventDateTime
      INTO #tmpInitialTraces 
      FROM ( SELECT OffenderID, 
	                  EventDateTime
	           FROM rprtEventsBucket1 (NOLOCK) Bucket1
	             INNER JOIN #tmpOffenderIDs tmpoff ON Bucket1.OffenderID = tmpoff.[number]
	           WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	         )x
	    GROUP BY OffenderID,
	             EventDateTime

      -- // Create index for performance // --
      CREATE CLUSTERED INDEX #xpkTmpInitialTraces ON #tmpInitialTraces(EventDateTime, OffenderID)

      -- // Main Query // --
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
        INNER JOIN #tmpInitialTraces tmptrc ON  evt.OffenderID = tmptrc.OffenderID 
		AND evt.EventDateTime = tmptrc.EventDateTime
        INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID
      WHERE evt.EventDateTime = (SELECT MAX(EventDateTime)
                                 FROM #tmpInitialTraces (NOLOCK) tmptrc1 
                                 WHERE tmptrc1.OffenderID = evt.OffenderID)
    END
  ELSE IF ((@StartDate < @HighWaterMark) AND (@EndDate < @HighWaterMark))
     --IF (@StartDate < DATEADD(MINUTE, -4320, GETDATE()))
    -- // Date range is entirely in bucket2 // --
    BEGIN
      SELECT OffenderID,
             MAX(EventDateTime) AS EventDateTime
      INTO #tmpInitialTraces2 
      FROM ( SELECT OffenderID, 
	                  EventDateTime
	           FROM rprtEventsBucket2 (NOLOCK) Bucket2
	             INNER JOIN #tmpOffenderIDs tmpoff ON Bucket2.OffenderID = tmpoff.[number]
	           WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	         )y
	    GROUP BY OffenderID,
	             EventDateTime

      -- // Create index for performance // --
      CREATE CLUSTERED INDEX #xpkTmpInitialTraces2 ON #tmpInitialTraces2(EventDateTime, OffenderID)

      -- // Main Query // --
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
      FROM rprtEventsBucket2 (NOLOCK) evt
      INNER JOIN EventType typ ON evt.EventID=typ.EventTypeID
        INNER JOIN #tmpInitialTraces2 tmptrc ON evt.OffenderID = tmptrc.OffenderID
	             AND evt.EventDateTime = tmptrc.EventDateTime
        INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID
      WHERE evt.EventDateTime = (SELECT MAX(EventDateTime)
                                 FROM #tmpInitialTraces2 (NOLOCK) tmptrc1 
                                 WHERE tmptrc1.OffenderID = evt.OffenderID)
    END
  ELSE
    -- // Date Range spans the buckets // --
    BEGIN
      SELECT OffenderID,
             MAX(EventDateTime) AS EventDateTime
      INTO #tmpInitialTraces1 
      FROM ( SELECT OffenderID, 
	                  EventDateTime
	           FROM rprtEventsBucket1 (NOLOCK) Bucket1
	             INNER JOIN #tmpOffenderIDs tmpoff ON Bucket1.OffenderID = tmpoff.[number]
	           WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)	    
            	    
             UNION ALL          

             SELECT OffenderID, 
                    EventDateTime
             FROM rprtEventsBucket2 (NOLOCK) Bucket2
               INNER JOIN #tmpOffenderIDs tmpoff ON Bucket2.OffenderID = tmpoff.[number]
             WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)            	
	         )z
	    GROUP BY OffenderID,
	             EventDateTime

      -- // Create index for performance // --
      CREATE CLUSTERED INDEX #xpkTmpInitialTraces1 ON #tmpInitialTraces1(EventDateTime, OffenderID)

      -- // Main Query // --
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
        INNER JOIN #tmpInitialTraces1 tmptrc ON evt.OffenderID = tmptrc.OffenderID
	             AND evt.EventDateTime = tmptrc.EventDateTime
        INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID
      WHERE evt.EventDateTime = (SELECT MAX(EventDateTime)
                                 FROM #tmpInitialTraces1 (NOLOCK) tmptrc1 
                                 WHERE tmptrc1.OffenderID = evt.OffenderID)
      
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
        INNER JOIN #tmpInitialTraces1 tmptrc2 ON evt2.OffenderID = tmptrc2.OffenderID
	             AND evt2.EventDateTime = tmptrc2.EventDateTime
        INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID
      WHERE evt2.EventDateTime = (SELECT MAX(EventDateTime)
                                  FROM #tmpInitialTraces1 (NOLOCK) tmptrc2
                                  WHERE tmptrc2.OffenderID = evt2.OffenderID)
    END  
END

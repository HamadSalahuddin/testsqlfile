USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetMostRecentTrace]    Script Date: 10/04/2011 10:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- File Name:   spTPal_Ofn_GetMostRecentTrace.sql
-- Author:		  Sajid
-- Create date: 17-May-2010
-- Description:	Gets most recent of all event traces between given dates for given Offenders 
--              belonging to a specific agency if that trace is within the area of given radius.
-- Modified By: R.Cole 6/1/2010 - Added condition so we are only returning the latest trace.
--              SABBASI 22-Jun-21- We want to return latest traces with in given dates. 
--                This is result of a change in requirements.
--              R.Cole 8/17/2010 - Added EventPrimaryID to the CTE and ResultSet.
--              SABBASI 30-Aug-10 - Change to Note Count
--              SABBASI 16-Nov-2010; Need to get most recent traces and all Alrms. AlarmType is
--                basically EventTypeID field of EventType table.
--              R.Cole 16-Nov-2010; Modified to return both the most recent trace for each offender,
--                but also all alarms for the offenders, in the given timeframe and area.
--              R.Cole 17-Nov-2010; Added filter to prevent non-plottable, non-alarm events
--                from being returned as the latest 'event'.
--				      S.Florek 6-Dec-2010 Rewrote the whole thing due to crummy performance.
--              R.Cole 15-Dec-2010: Removed the retrievel of events as redunant, application
--                polling already has the events.
--              R.Cole 27-Dec-10: Added missing GeoRule name field.
--              SABBASI 01-Feb-11: Added space in offender name field
--              R.Cole 04-Oct-11: Added code to minimize bucket utilization.
--              R.Cole - 10/05/2011: Added code to use highwatermark instead of date compares.
--              R.Cole - 10/18/2011: Fixed a bug in the conditional logic for bucket choice
-- =============================================
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetMostRecentTrace] (
	@AgencyIDs VARCHAR(MAX),
	@StartDate DateTime,
	@EndDate DateTime,
	@CenterPointlat FLOAT,
	@CenterPointlong FLOAT,
	@radius FLOAT,
	@OfficerIDs VARCHAR(MAX), 
	@OffenderIDs VARCHAR(MAX)
)	 
AS
BEGIN
  SET NOCOUNT ON;

  -- // HighWaterMark // --
  DECLARE @HighWaterMark DATETIME
  SET @HighWaterMark = (SELECT RTM_HighTime FROM RTM_TableState WHERE RTM_TableName LIKE 'BucketMover_Bucket1')

  --Extract OffenderIDs into a temp table
  SELECT [number]
  INTO #tmpOffenderIDs
  FROM GetTableFromListId(@OffenderIDs)

  CREATE CLUSTERED INDEX #xpktmpOffender ON #tmpOffenderIDs(number)
  
  IF ((@StartDate > @HighWaterMark) AND (@EndDate > @HighWatermark))
--  IF ((@StartDate > DATEADD(MINUTE, -4320, GETDATE())) AND (@EndDate > DATEADD(MINUTE, -4320, GETDATE())))
    -- // Daterange is entirely in Bucket1 // --
    BEGIN
      SELECT OffenderID,
         EventDateTime
      INTO #tmpInitialTraces1
      FROM (SELECT OffenderID, 
	                 EventDateTime
	          FROM rprtEventsBucket1 (NOLOCK) Bucket1
	            INNER JOIN #tmpOffenderIDs tmpoff ON Bucket1.OffenderID = tmpoff.[number]
	          WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	            AND AlarmID IS NOT NULL
	         )x
     	GROUP BY OffenderID,
	             EventDateTime  
	   
     CREATE CLUSTERED INDEX #xpkTmpInitialTraces1 ON #tmpInitialTraces1(EventDateTime, OffenderID)          
     
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
            ( (SELECT COUNT(AlarmNoteID) 
               FROM AlarmNote (NOLOCK)
               WHERE AlarmID = evt.AlarmID ) + (SELECT COUNT(EventNoteID) 
                                                FROM EventNote (NOLOCK)
                                                WHERE DeviceID = evt.DeviceID 
                                                  AND EventTime = evt.EventTime 
                                                  AND EventID = evt.EventID)
            ) AS 'NoteCount'	
     FROM rprtEventsBucket1 (NOLOCK) evt
       INNER JOIN #tmpInitialTraces1 tmptrc1 ON evt.OffenderID = tmptrc1.OffenderID
              AND evt.EventDateTime = tmptrc1.EventDateTime
       INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID
	    
    END
  ELSE IF ((@StartDate < @HighWaterMark) AND (@EndDate < @HighWaterMark))
     --IF @StartDate < DATEADD(MINUTE, -4320, GETDATE())
    -- // Daterange is entirely in Bucket2 // --
    BEGIN
      SELECT OffenderID,
             EventDateTime
      INTO #tmpInitialTraces2 
      FROM (SELECT OffenderID, 
	                 EventDateTime
	          FROM rprtEventsBucket2 (NOLOCK) Bucket2
	            INNER JOIN #tmpOffenderIDs tmpoff ON Bucket2.OffenderID = tmpoff.[number]
	          WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	            AND AlarmID IS NOT NULL 
	         )y   
	   	GROUP BY OffenderID,
	             EventDateTime  
	         
      CREATE CLUSTERED INDEX #xpkTmpInitialTraces2 ON #tmpInitialTraces2(EventDateTime, OffenderID)

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
             ( (SELECT COUNT(AlarmNoteID) 
                FROM AlarmNote (NOLOCK)
                WHERE AlarmID = evt2.AlarmID ) + (SELECT COUNT(EventNoteID) 
                                                 FROM EventNote (NOLOCK)
                                                 WHERE DeviceID = evt2.DeviceID 
                                                   AND EventTime = evt2.EventTime 
                                                   AND EventID = evt2.EventID)
             ) AS 'NoteCount'	
      FROM rprtEventsBucket2 (NOLOCK) evt2
        INNER JOIN #tmpInitialTraces2 tmptrc2 ON evt2.OffenderID = tmptrc2.OffenderID
	             AND evt2.EventDateTime = tmptrc2.EventDateTime
        INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID
    END
  ELSE
    -- // Daterange spans Bucket1 and Bucket2 // --
    BEGIN
      SELECT OffenderID,
             EventDateTime
      INTO #tmpInitialTraces 
      FROM ( 
	      SELECT OffenderID, 
	             EventDateTime
	      FROM rprtEventsBucket1 (NOLOCK) Bucket1
	        INNER JOIN #tmpOffenderIDs tmpoff ON Bucket1.OffenderID = tmpoff.[number]
	      WHERE (EventDateTime BETWEEN @StartDate AND @EndDate)
	        AND AlarmID IS NOT NULL
    	    
      UNION ALL  

	      SELECT OffenderID, 
	             EventDateTime
	      FROM rprtEventsBucket2 (NOLOCK) Bucket2
	        INNER JOIN #tmpOffenderIDs tmpoff ON Bucket2.OffenderID = tmpoff.[number]
	      WHERE 
	      (EventDateTime BETWEEN @StartDate AND @EndDate)
	      AND AlarmID IS NOT NULL
	      )z
	     GROUP BY OffenderID,
	              EventDateTime

      CREATE CLUSTERED INDEX #xpkTmpInitialTraces ON #tmpInitialTraces(EventDateTime, OffenderID)

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
             ( (SELECT COUNT(AlarmNoteID) 
                FROM AlarmNote (NOLOCK)
                WHERE AlarmID = evt.AlarmID ) + (SELECT COUNT(EventNoteID) 
                                                 FROM EventNote (NOLOCK)
                                                 WHERE DeviceID = evt.DeviceID 
                                                   AND EventTime = evt.EventTime 
                                                   AND EventID = evt.EventID)
             ) AS 'NoteCount'	
      FROM rprtEventsBucket1 (NOLOCK) evt
        INNER JOIN #tmpInitialTraces tmptrc ON evt.OffenderID = tmptrc.OffenderID
	             AND evt.EventDateTime = tmptrc.EventDateTime
        INNER JOIN Offender (NOLOCK) ofn ON evt.OffenderID = ofn.OffenderID

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
             ( (SELECT COUNT(AlarmNoteID) 
                FROM AlarmNote (NOLOCK)
                WHERE AlarmID = evt2.AlarmID ) + (SELECT COUNT(EventNoteID) 
                                                 FROM EventNote (NOLOCK)
                                                 WHERE DeviceID = evt2.DeviceID 
                                                   AND EventTime = evt2.EventTime 
                                                   AND EventID = evt2.EventID)
             ) AS 'NoteCount'	
      FROM rprtEventsBucket2 (NOLOCK) evt2
        INNER JOIN #tmpInitialTraces tmptrc2 ON evt2.OffenderID = tmptrc2.OffenderID
	             AND evt2.EventDateTime = tmptrc2.EventDateTime
        INNER JOIN Offender (NOLOCK) ofn2 ON evt2.OffenderID = ofn2.OffenderID    
    END
END

USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetTraces]    Script Date: 10/04/2011 15:16:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- File Name: spTPal_Ofn_GetTraces
-- Author:		Sajid Abbasi
-- Create date: 01-May-2010 
-- Description:	This procedure gets list of all event traces between given dates for
--              given Offenders belonging to specific agenies if that traces have 
--              been with the area of given radius.
-- Modified date: 23-Jul-2010
--                R.Cole - 8/18/2010: Added EventPrimaryID
--                  to CTE and Result set.
--                SABBASI - 30-Aug-10: Change to Note Count
--                S.Florek - 6-Dec-10: Revised for speed.
--                S.Florek - 15-Dec-10: Peformance tweak.
--                R.Cole - 27-Dec-10: Added missing GeoRule name field.
--                SABBASI - 1-Feb-11: Added space in offender name field.
--                R.Cole - 4-Oct-11: Added code to minimize bucket utilization
--                R.Cole - 10/05/2011: Added code to use highwatermark instead of date compares.
--                R.Cole - 10/18/2011: Fixed a bug in the conditional logic for bucket choice
-- =============================================
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetTraces] (
	@AgencyIDs Varchar(MAX),
	@StartDate DateTime,
	@EndDate DateTime,
	@CenterPointlat float=0,
	@CenterPointlong float=0,
	@radius float=0,
	@OfficerIDs Varchar(MAX), 
	@OffenderIDs Varchar(MAX)
)	 
AS
BEGIN
  SET NOCOUNT ON;
  
  -- // HighWaterMark // --
  DECLARE @HighWaterMark DATETIME
  SET @HighWaterMark = (SELECT RTM_HighTime FROM RTM_TableState WHERE RTM_TableName LIKE 'BucketMover_Bucket1')  

  --Extract OffenderIDs into a temp table
  select [number]
  into #tmpOffenderIDs
  from GetTableFromListId(@OffenderIDs)

  create clustered index #xpktmpOffender on #tmpOffenderIDs(number)
  IF ((@StartDate > @HighWaterMark) AND (@EndDate > @HighWatermark))
--  IF (@StartDate > DATEADD(MINUTE, -4320, GETDATE())) AND (@EndDate > DATEADD(MINUTE, -4320, GETDATE()))
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
             ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = evt.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                               FROM EventNote (NOLOCK)
	                                               WHERE DeviceID = evt.DeviceID 
	                                                 AND EventTime = evt.EventTime 
	                                                 AND EventID = evt.EventID)
	           ) AS 'NoteCount'	
      FROM rprtEventsBucket1 (NOLOCK) evt
	    JOIN #tmpOffenderIDs tmpoff on evt.OffenderID = tmpoff.number
	    JOIN Offender (NOLOCK) ofn on evt.OffenderID = ofn.OffenderID
	    WHERE
	    (EventDateTime BETWEEN @StartDate AND @EndDate)
	    AND ( @radius = 0 OR [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong, Latitude, Longitude) <= @radius )
    END
  ELSE IF ((@StartDate < @HighWaterMark) AND (@EndDate < @HighWaterMark))
     --IF @StartDate < DATEADD(MINUTE, -4320, GETDATE())
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
             ( (SELECT COUNT(AlarmNoteID) 
                FROM AlarmNote (NOLOCK)
                WHERE AlarmID = evt2.AlarmID ) + (SELECT COUNT(EventNoteID) 
                                                 FROM EventNote (NOLOCK)
                                                 WHERE DeviceID = evt2.DeviceID 
                                                   AND EventTime = evt2.EventTime 
                                                   AND EventID = evt2.EventID)
             ) AS 'NoteCount'	
      FROM rprtEventsBucket2 (NOLOCK) evt2
      JOIN #tmpOffenderIDs tmpoff2 on evt2.OffenderID = tmpoff2.number
      JOIN Offender (NOLOCK) ofn2 on evt2.OffenderID = ofn2.OffenderID
      WHERE
      (EventDateTime BETWEEN @StartDate AND @EndDate)
      AND ( @radius = 0 OR [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong, Latitude, Longitude) <= @radius )
    END
  ELSE
    -- // Daterange spans Bucket1 and Bucket2 // --
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
             ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = evt.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                               FROM EventNote (NOLOCK)
	                                               WHERE DeviceID = evt.DeviceID 
	                                                 AND EventTime = evt.EventTime 
	                                                 AND EventID = evt.EventID)
	           ) AS 'NoteCount'	
      FROM rprtEventsBucket1 (NOLOCK) evt
	    JOIN #tmpOffenderIDs tmpoff on evt.OffenderID = tmpoff.number
	    JOIN Offender (NOLOCK) ofn on evt.OffenderID = ofn.OffenderID
	    WHERE
	    (EventDateTime BETWEEN @StartDate AND @EndDate)
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
             ( (SELECT COUNT(AlarmNoteID) 
	              FROM AlarmNote (NOLOCK)
	              WHERE AlarmID = evt2.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                               FROM EventNote (NOLOCK)
	                                               WHERE DeviceID = evt2.DeviceID 
	                                                 AND EventTime = evt2.EventTime 
	                                                 AND EventID = evt2.EventID)
	           ) AS 'NoteCount'	
      FROM rprtEventsBucket2 (NOLOCK) evt2
	    JOIN #tmpOffenderIDs tmpoff2 on evt2.OffenderID = tmpoff2.number
	    JOIN Offender (NOLOCK) ofn2 on evt2.OffenderID = ofn2.OffenderID
	    WHERE
	    (EventDateTime BETWEEN @StartDate AND @EndDate)
	    AND ( @radius = 0 OR [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong, Latitude, Longitude) <= @radius )
    END
END

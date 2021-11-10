USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[EventGetByOffenderID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[EventGetByOffenderID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO


/* **********************************************************
 * FileName:   EventGetByOffenderID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     <Redmine #>      
 * Purpose:    Get Events by OffenderID               
 *
 * Modified By: R.Cole - 02/17/2010 - Task: 736 (Temporary)
 *              R.Cole - 05/04/2010 - Task: 920 (Temporary)
 *              R.Cole - 05/24/2010 - Task: 925 Addresses
 *              will only be returned when we have valid
 *              GPS.
 *              R.Cole - 6/29/2010 - Task: 1049  Modified
 *              SProc so that addresses will always be
 *              returned for eArrest events. 
 * ******************************************************** */
CREATE PROCEDURE [EventGetByOffenderID] (
	    @StartDate DATETIME,
	    @EndDate DATETIME,
	    @EventTypeID INT,
	    @OffenderID INT,
	    @SO INT,
	    @OPR INT,
	    @EventTypeGroupID INT 
    )
AS

-- // Define the CTE // --
WITH Events_CTE AS
(
  SELECT DeviceID,
         TrackerNumber,
         EventTime,
         EventDateTime,
         EventID,
         AlarmType,
         AlarmAssignmentStatusName,
         Longitude,
         Latitude,
         [Address],
         OffenderID,
         AlarmID,
         GpsValid,
         GpsValidSatellites,
         GeoRule,
         SO,
         OPR,
         EventTypeGroupID,
         OffenderName,
         OffenderDeleted        
  FROM rprtEventsBucket2
  WHERE EventDateTime BETWEEN @StartDate AND @EndDate 
    AND OffenderID = @OffenderID
    
  UNION
  
  SELECT DeviceID,
         TrackerNumber,
         EventTime,
         EventDateTime,
         EventID,
         AlarmType,
         AlarmAssignmentStatusName,
         Longitude,
         Latitude,
         [Address],
         OffenderID,
         AlarmID,
         GpsValid,
         GpsValidSatellites,
         GeoRule,
         SO,
         OPR,
         EventTypeGroupID,
         OffenderName,
         OffenderDeleted
  FROM rprtEventsBucket1
  WHERE EventDateTime BETWEEN @StartDate AND @EndDate 
    AND OffenderID = @OffenderID
)
SELECT * INTO #tmpEvent FROM Events_CTE

/* ============== Dev Use =============
SELECT * FROM #tmpEvent
DROP TABLE #tmpEvent
====================================== */

-- // Main Query // --
SELECT tEvent.DeviceID, 
	     tEvent.TrackerNumber,
	     tEvent.EventTime, 
	     tEvent.EventDateTime,
	     tEvent.EventID,
	     ISNULL(tEvent.AlarmType, 1) AS 'AlarmType', -- 1: notification
	     ISNULL(tEvent.[AlarmAssignmentStatusName],'Unassigned') AS 'AlarmAssignmentStatusName',
	     EventType.AbbrevEventType as EventName,
	     ISNULL(ROUND(tEvent.Longitude,5), 0) AS 'Longitude',
	     ISNULL(ROUND(tEvent.Latitude,5), 0) AS 'Latitude',
 	     CASE WHEN (GpsValid = 1 OR tEvent.EventID IN (176,177,178,179,180,181,182,184,185,192,193,194,195)) THEN tEvent.Address 
 	          ELSE 'Address Unavailable' END AS 'Address',
	     tEvent.OffenderName,
	     tEvent.OffenderID,
	     ( (SELECT COUNT(AlarmNoteID) 
	        FROM AlarmNote 
	        WHERE AlarmID = tEvent.AlarmID ) + (SELECT COUNT(EventNoteID) 
	                                            FROM EventNote 
	                                            WHERE DeviceID = tEvent.DeviceID 
	                                              AND EventTime = tEvent.EventTime 
	                                              AND EventID = tEvent.EventID)
	     ) AS 'NoteCount',
	     tEvent.AlarmID,
	     ISNULL(tEvent.GpsValid,0) AS 'GpsValid',
	     ISNULL(tEvent.GpsValidSatellites,0) AS 'GpsValidSatellites',
	     tEvent.GeoRule
FROM #tmpEvent tEvent
  INNER JOIN EventType ON EventType.EventTypeID = tEvent.EventID
WHERE ((@EventTypeID < 0 ) OR (EventID = @EventTypeID))
  AND ((@SO < 0) OR (tEvent.SO = @SO))
  AND ((@OPR < 0) OR (tEvent.OPR = @OPR))
  AND ((@EventTypeGroupID < 0) OR (tEvent.EventTypeGroupID = @EventTypeGroupID))
  AND tEvent.OffenderDeleted = 0
ORDER BY EventDateTime DESC, 
	       AlarmType

-- // Clean up the temp table // --
DROP TABLE #tmpEvent
GO

GRANT EXECUTE ON [EventGetByOffenderID] TO [db_dml]
GO
USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[CourtReport]    Script Date: 3/4/2021 7:12:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   CourtReport.sql
 * Created On: 01/26/2010
 * Created By: R.Cole
 * Task #:		 SA_657
 * Purpose:    Return Data for the CourtReport conversion
 *             from Navteq to Google maps               
 *
 * Modified By: R.Cole - 04/20/2010: SA 876 - Added ORDER BY  
 *              to the section that gets the notes, they will 
 *              now be returned in correct chronological order 
 *              in the resultset 
 *              R.Cole - 09/16/2014: #6811 - Fixed an issue
 *              where the GeoRule name was not correctly being
 *              returned.
 *              R.Cole - 11/14/2014: #6434 - Removed Operator 
 *              Names from Event/Alarm Notes. 
 *				Sohail - 1 Oct 2015:Task # 6546 - joined bucket1 
 *				and bucket 2 with Gateway tables to get the beacon 
 *				serial number and then used fnGetbeaconaddress function 
 *				to get the beacon address and added that address in 
 *				the select statement then modified the case for GPS 
 *				valid and used beacon address if GPS is invalid and 
 *				the event is a beacon event
 *        R.Cole - 10/1/2015: Merged code with US Live.  
 *			D. Riding 3/3/21 - 	#14237/TPL-426 - Use the GeoRule from the bucket tables instead of from 
 *									the GeoRule_Offender/GeoRule tables since the ZoneID changes 
 * 									for the zones every time the rules are uploaded, which was leading 
 * 									to incorrect zone names displaying. Use the GeoRule column of the bucket tables instead.
 *
 * Ron's TODO:  Add logic to ensure the query only touches the 
 *         appropriate bucket for the time frame passed in.
 *         utilize high watermarks.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[CourtReport] (
  @AgencyID INT,
  @OffenderID INT,
  @StartDate DATETIME,
  @EndDate DATETIME  
)
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* *********************
 *     Get Events 
 ********************* */
Select e.EventPrimaryID,
       e.DeviceID,
       e.EventTime,
       e.EventDateTime,
       e.ReceivedTime,
       e.TrackerNumber,
       e.EventID,
       e.AlarmType,
       e.AlarmAssignmentStatusID,
       e.AlarmAssignmentStatusName,
       e.EventName,
       e.Longitude,
       e.Latitude,
       e.Address,
       e.OffenderID,
       e.NoteCount,
       e.AlarmID,
       e.GpsValid,
       e.GpsValidSatellites,
       e.GeoRule,
       e.SO,
       e.OPR,
       e.OfficerID,
       e.AgencyID,
       e.AcceptedDate,
       e.AcceptedBy,
       e.ActivateDate,
       e.DeactivateDate,
       e.EventParameter,
       e.EventTypeGroupID,
       e.EventQueueID,
       e.OffenderName,
       e.OffenderDeleted,
       e.BeaconAddress
INTO #tmpCourtReport
FROM (SELECT EventPrimaryID,
             Bucket1.DeviceID,
             Bucket1.EventTime,
             EventDateTime,
             Bucket1.ReceivedTime,
             TrackerNumber,
             Bucket1.EventID,
             AlarmType,
             AlarmAssignmentStatusID,
             AlarmAssignmentStatusName,
             EventName,
             Bucket1.Longitude,
             Bucket1.Latitude,
             Bucket1.Address,
             OffenderID,
             NoteCount,
             AlarmID,
             Bucket1.GpsValid,
             Bucket1.GpsValidSatellites,
             GeoRule,
             SO,
             OPR,
             OfficerID,
             AgencyID,
             AcceptedDate,
             AcceptedBy,
             ActivateDate,
             DeactivateDate,
             Bucket1.EventParameter,
             EventTypeGroupID,
             EventQueueID,
             OffenderName,
             OffenderDeleted,
             Trackerpal.dbo.fnGetbeaconaddress(gwEvents.BeaconSerialNumber,Bucket1.OffenderID) AS BeaconAddress
      FROM rprtEventsBucket1 Bucket1 WITH (NOLOCK)
       LEFT JOIN Gateway.dbo.Events gwEvents ON Bucket1.DeviceID = gwEvents.DeviceID
		        AND Bucket1.EventID = gwEvents.EventID 
		        AND Bucket1.EventTime = gwEvents.EventTime   
	   LEFT JOIN Gateway.dbo.Devices gwDevices ON Bucket1.DeviceID = gwDevices.DeviceID
      UNION ALL
      SELECT EventPrimaryID,
             Bucket2.DeviceID,
             Bucket2.EventTime,
             EventDateTime,
             Bucket2.ReceivedTime,
             TrackerNumber,
             Bucket2.EventID,
             AlarmType,
             AlarmAssignmentStatusID,
             AlarmAssignmentStatusName,
             EventName,
             Bucket2.Longitude,
             Bucket2.Latitude,
             Bucket2.Address,
             OffenderID,
             NoteCount,
             AlarmID,
             Bucket2.GpsValid,
             Bucket2.GpsValidSatellites,
             GeoRule,
             SO,
             OPR,
             OfficerID,
             AgencyID,
             AcceptedDate,
             AcceptedBy,
             ActivateDate,
             DeactivateDate,
             Bucket2.EventParameter,
             EventTypeGroupID,
             EventQueueID,
             OffenderName,
             OffenderDeleted,
             Trackerpal.dbo.fnGetbeaconaddress(gwEvents.BeaconSerialNumber,Bucket2.OffenderID) AS BeaconAddress
      FROM rprtEventsBucket2 Bucket2 WITH (NOLOCK)
       LEFT JOIN Gateway.dbo.Events gwEvents ON Bucket2.DeviceID = gwEvents.DeviceID
		        AND Bucket2.EventID = gwEvents.EventID 
		        AND Bucket2.EventTime = gwEvents.EventTime   
	   LEFT JOIN Gateway.dbo.Devices gwDevices ON Bucket2.DeviceID = gwDevices.DeviceID) e
WHERE e.EventDatetime >= @StartDate 
  AND e.EventDatetime <= @EndDate
  AND e.OffenderID = @OffenderID

/* *********************************
 *    Create Temp EventNotes Table
 ******************************** */
DECLARE @EventNotesTemp
TABLE (
  NOTES VARCHAR(2000), 
  EVENTID INT, 
  EVENTTIME BIGINT, 
  DEVICEID INT, 
  USERID INT,
  CREATEDDATE DATETIME 
)

INSERT INTO @EventNotesTemp (
  NOTES , 
  EVENTID, 
  EVENTTIME, 
  DEVICEID,
  USERID,
  CREATEDDATE
)

/* *****************************
 *        Get Event Notes
 * *************************** */
SELECT CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),101) + ' ' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),108) + ':' + en.note,
--SELECT ISNULL(co.FirstName + ' ', '') + ISNULL(co.MiddleName + ' ', '') + ISNULL(co.LastName, '') + '-' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),101) + ' ' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),108) + ':' + en.note,
       E.EVENTID,
       E.EVENTTIME,
       E.DEVICEID, 
       EN.CreatedByID,
       en.CreatedDate
FROM EventNote EN WITH (NOLOCK)
	LEFT JOIN #tmpCourtReport e ON en.DeviceID = e.DeviceID 
	      AND en.EventTime = e.EventTime 
	      AND en.EventID = e.EventID
	LEFT JOIN EventType et ON e.EventID = et.EventTypeID
	INNER JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID 
	       AND ((ota.activateDate< CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		           AND ota.DeActivateDate> CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,	DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))))
		          OR (ota.activateDate<CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		           AND ota.DeActivateDate IS NULL))
	LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID 
	      AND o.Deleted = 0
	LEFT JOIN operator co on co.userid= en.createdByID
WHERE (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))) >= @StartDate 
	AND CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))	<= @EndDate)
	AND o.OffenderID = @OffenderID
	AND et.SO = 1                     -- // Only show events that are available to the SO //--

UNION 

/* *************************
 *      Get Alarm Notes
 ************************ */
SELECT CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),101 )+ ' ' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),108 )+ ':' + an.note,
--SELECT ISNULL(co.FirstName + ' ', '') + ISNULL(co.MiddleName + ' ', '') + ISNULL(co.LastName, '') + '-' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),101 )+ ' ' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),108 )+ ':' + an.note,
       E.EVENTID,
       E.EVENTTIME,
       E.DEVICEID, 
       AN.CreatedByID,
       an.CreatedDate
FROM AlarmNote AN WITH (NOLOCK)
	LEFT JOIN Alarm a ON A.ALARMID = AN.ALARMID
	LEFT JOIN #tmpCourtReport e ON e.DeviceID = a.TrackerID 
		    AND e.EventTime = a.EventTime 
		    AND e.EventID = a.EventTypeID
	LEFT JOIN EventType et ON e.EventID = et.EventTypeID
	INNER JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID 
	       AND ((ota.activateDate< CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		           AND ota.DeActivateDate> CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))))
		          OR (ota.activateDate<CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		           AND ota.DeActivateDate IS NULL))
	LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID 
	      AND o.Deleted = 0
	LEFT JOIN operator co ON co.userid= an.createdByID
WHERE (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))) >= @StartDate 
	AND CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,	DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))) <= @EndDate)
	AND o.OffenderID = @OffenderID
	AND et.SO = 1                     -- // Only show events that are available to the SO //--
ORDER BY CreatedDate 

/* ***************************
 *    Build Final Result Set 
 *************************** */
SELECT ISNULL(o.FirstName + ' ', '') + ISNULL(o.MiddleName + ' ', '') + ISNULL(o.LastName, '') AS 'Offender',
	     ISNULL(so.FirstName + ' ', '') + ISNULL(so.LastName, '') AS 'Officer',	
	     ag.Agency,
	     CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))) AS 'EventTime',
--	     (trackerpal.dbo.fnUtcToLocal(@AgencyID, (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))))) AS 'EventTime', 
	     (CASE WHEN a.EventTypeID = 256 AND a.EventParameter > 0
			       THEN et.AbbrevEventType + ' ' + CONVERT(NVARCHAR(4),a.EventParameter)
			       ELSE et.AbbrevEventType
		    END) AS 'EventName',
	     (CASE WHEN et.EventTypeGroupID = 5
	     			 THEN ISNULL(e.GeoRule, 'N/A') 
			       ELSE 'N/A'
		    END) AS 'GeoRule',
		    --NOTE:TrackerMap does not use GPSvalid field db value instead it generates its own value based on lat lng info.
		    --	   if lat/lng is 0 then GPSValid=0 else 1.so we have to use lat lng here rather then GPSValid.Task 8546 
       (CASE WHEN e.Latitude!=0 AND e.Longitude!=0 --e.Gpsvalid > 0 OR e.eventid IN (176,177,178,179,180,181,182,184,185,192,193,194,195) 
             THEN e.Address
             WHEN e.Latitude=0 AND e.Longitude=0  AND e.eventid IN (176,177,178,179,180,181,182,184,185,192,193,194,195)
             THEN e.BeaconAddress
             ELSE 'unavailable' END) AS 'Location',
       CASE WHEN aa.AssignedDate IS NOT NULL
            THEN aa.AssignedDate
            ELSE ISNULL(EN.CREATEDDATE,(CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))))) END AS 'AcceptedDate',
       '' AS Operator,
	     ISNULL(EN.nOTES,'') AS Notes, 	
	     ISNULL(ROUND(e.Latitude,5), 0) AS 'Latitude',
	     ISNULL(ROUND(e.Longitude,5), 0) AS 'Longitude',
	     ISNULL(e.GpsValid,0) AS 'GpsValid',
	     ISNULL(e.GpsValidSatellites,0) AS 'GpsValidSatellites',	
	     @StartDate AS 'StartDateAgency',
	     @EndDate AS 'EndDateAgency',
	     dbo.fnGetUtcOffset(@AgencyID) AS 'utcoffset',
	     e.EventID,
	     o.OffenderID
FROM #tmpCourtReport e WITH (NOLOCK)
	LEFT JOIN EventType et ON e.EventID = et.EventTypeID
	LEFT JOIN Alarm a ON e.DeviceID = a.TrackerID 
		    AND e.EventTime = a.EventTime 
		    AND e.EventID = a.EventTypeID
	INNER JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID 
	      AND ((ota.activateDate< CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		          AND ota.DeActivateDate> CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))))
		        OR (ota.activateDate<CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		          AND ota.DeActivateDate IS NULL))
	LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID 
	      AND o.Deleted = 0
	LEFT JOIN Offender_Officer oo ON oo.OffenderID = o.OffenderID
	LEFT JOIN Officer so ON so.OfficerID = oo.OfficerID
	LEFT JOIN Agency ag ON ag.AgencyID = so.AgencyID
	LEFT JOIN AlarmAssignment aa ON a.alarmId = aa.alarmid 
	      AND aa.AssignedDate = (SELECT MAX(AssignedDate) 
	                             FROM AlarmAssignment AAD 
	                             WHERE aad.AlarmID = a.AlarmID 
	                               AND aad.alarmassignmentStatusID = 2) 
	      AND aa.alarmassignmentStatusID = 2
	LEFT JOIN @EventNotesTemp EN ON en.DeviceID = e.DeviceID 
	      AND en.EventTime = e.EventTime 
	      AND en.EventID = e.EventID
	LEFT JOIN operator oa ON aa.AssignedToID = oa.userid
	LEFT JOIN operator op ON EN.USERID = op.userid
WHERE (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))) >= @StartDate 
	AND CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))) <= @EndDate)
	AND o.OffenderID = @OffenderID
  AND et.SO = 1                     -- // Only show events that are available to the SO //--
ORDER BY e.EventTime DESC, 
         e.AlarmType

/* **********************
 *    Perform Clean Up
 ********************** */
DROP TABLE #tmpCourtReport

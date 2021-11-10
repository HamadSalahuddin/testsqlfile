USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[ReportCourt2WithNotesDetail]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReportCourt2WithNotesDetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   ReportCourt2WithNotesDetail.sql
 * Created On: 01/26/2010
 * Created By: R.Cole
 * Task #:		 SA_657
 * Purpose:    Return Data for the CourtReport conversion
 *             from Navteq to Google maps               
 *
 * Modified By: 
 * ******************************************************** */
CREATE PROCEDURE [ReportCourt2WithNotesDetail] (
  @StartDate DATETIME,
  @EndDate DATETIME,
  @OffenderID INT,
	@AgencyID	INT
)

AS

SET @StartDate = trackerpal.dbo.fnLocalToUtc(@AgencyID, @StartDate)
SET @EndDate = trackerpal.dbo.fnLocalToUtc(@AgencyID, @EndDate)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Get Events // --
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
       e.OffenderDeleted
INTO #tempcourt2withnotes
FROM (SELECT * from rprteventsbucket1 WITH (NOLOCK)
      UNION ALL
      SELECT * from rprteventsbucket2 WITH (NOLOCK)) e
WHERE e.EventDatetime >= @StartDate 
  AND e.EventDatetime <= @EndDate
  AND e.OffenderID = @OffenderID

-- // EventNotes // --
DECLARE @EventNotesTemp
TABLE (NOTES VARCHAR(2000) , 
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

SELECT ISNULL(co.FirstName + ' ', '') + ISNULL(co.MiddleName + ' ', '') + ISNULL(co.LastName, '') + '-' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),101) + ' ' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),108) + ':' + en.note,
       E.EVENTID,
       E.EVENTTIME,
       E.DEVICEID, 
       EN.CreatedByID,
       en.CreatedDate
FROM EVENTNOTE EN WITH (NOLOCK)
	LEFT JOIN #tempcourt2withnotes e ON en.DeviceID = e.DeviceID 
	      AND en.EventTime = e.EventTime 
	      AND en.EventID = e.EventID
	LEFT JOIN EventType et ON e.EventID = et.EventTypeID
	INNER JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID 
	       AND ((ota.activateDate< CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		           AND ota.DeActivateDate> CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,	DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))))
		          OR (ota.activateDate<CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
		           AND ota.DeActivateDate is null))
	LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID 
	      AND o.Deleted = 0
	LEFT JOIN operator co on co.userid= en.createdByID
WHERE (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))) >= @StartDate 
	AND CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))	<= @EndDate)
	AND o.OffenderID = @OffenderID
	AND et.SO = 1 /*only the events that are available to So*/

UNION 

SELECT ISNULL(co.FirstName + ' ', '') + ISNULL(co.MiddleName + ' ', '') + ISNULL(co.LastName, '') + '-' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),101 )+ ' ' + CONVERT(VARCHAR,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),108 )+ ':' + an.note,
       E.EVENTID,
       E.EVENTTIME,
       E.DEVICEID, 
       AN.CreatedByID,
       an.CreatedDate
FROM ALARMNOTE AN WITH (NOLOCK)
	LEFT JOIN Alarm a ON A.ALARMID = AN.ALARMID
	LEFT JOIN #tempcourt2withnotes e ON e.DeviceID = a.TrackerID 
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
	AND et.SO = 1                   -- //only the events that are available to SO // --
-- // END EventNotes // --

-- // Final Result Set // --
SELECT ISNULL(o.FirstName + ' ', '') + ISNULL(o.MiddleName + ' ', '') + ISNULL(o.LastName, '') AS 'Offender',
	     ISNULL(so.FirstName + ' ', '') + ISNULL(so.LastName, '') AS 'Officer',	
	     ag.Agency,
	     (trackerpal.dbo.fnUtcToLocal(@AgencyID, (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))))) AS 'Event Time', 
	     (CASE WHEN a.EventTypeID = 256 AND a.EventParameter > 0
			       THEN et.AbbrevEventType + ' ' + CONVERT(NVARCHAR(4),a.EventParameter)
			       ELSE et.AbbrevEventType
		    END) AS 'Event Name',
	     (CASE WHEN et.EventTypeGroupID = 5
	     			 THEN gr.GeoRuleName 
			       ELSE 'N/A'
		    END) AS 'Geo Rule',
       (CASE WHEN e.Gpsvalid > 0 OR e.eventid IN (176,177,178,179,180,181,182,184,185,192,193,194,195)
             THEN e.Address
             ELSE 'Unavailable' END) AS 'Location',
       CASE WHEN aa.AssignedDate IS NOT NULL 
            THEN trackerpal.dbo.fnUtcToLocal(@AgencyID,aa.AssignedDate) 
            ELSE trackerpal.dbo.fnUtcToLocal(@AgencyID,EN.CREATEDDATE) END AS 'Accepted Date',
	     CASE WHEN oa.FirstName is null 
	          THEN ISNULL(op.FirstName + ' ', '') + ISNULL(op.MiddleName + ' ', '') + ISNULL(op.LastName, '')
	          ELSE ISNULL(oa.FirstName + ' ', '') + ISNULL(oa.MiddleName + ' ', '') + ISNULL(oa.LastName, '')	END AS 'Operator',
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
FROM #tempcourt2withnotes e WITH (NOLOCK)
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
	LEFT JOIN GeoRule gr ON gr.GeoRuleID = e.EventParameter
	LEFT JOIN @EventNotesTemp EN ON en.DeviceID = e.DeviceID 
	      AND en.EventTime = e.EventTime 
	      AND en.EventID = e.EventID
	LEFT JOIN operator oa ON aa.AssignedToID = oa.userid
	LEFT JOIN operator op ON EN.USERID = op.userid
WHERE (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))>= @StartDate 
	AND CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))<= @EndDate)
	AND o.OffenderID = @OffenderID
  AND et.SO = 1             -- // only the events that are available to S0 // --
ORDER BY e.EventTime ASC, 
         e.AlarmType

-- // Clean Up // --
DROP TABLE #tempcourt2withnotes
GO

-- // Permissions // --
GRANT EXECUTE ON [ReportCourt2WithNotesDetail] TO [db_dml]
GO
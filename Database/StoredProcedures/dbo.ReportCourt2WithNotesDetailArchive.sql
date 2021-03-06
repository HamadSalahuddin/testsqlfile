/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportCourt2WithNotesDetailArchive]

        @StartDate                      datetime,
        @EndDate                        datetime,
        @OffenderID                     int,
	@AgencyID			int

AS

set @StartDate = trackerpal.dbo.fnLocalToUtc(@AgencyID, @StartDate)
set @EndDate = trackerpal.dbo.fnLocalToUtc(@AgencyID, @EndDate)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
Select e.*
INTO #tempcourt2withnotes
FROM
Trackerpal_Archive.dbo.rprteventsbucket2 e WITH (NOLOCK)
--FROM fnAllEvents()
Where e.EventDatetime >= @StartDate And e.EventDatetime <= @EndDate
And e.Offenderid = @offenderid



/*EventNotes*/
DECLARE
@EventNotesTemp
TABLE 
(
 NOTES varchar(2000) , EVENTID int, EVENTTIME BIGINT, DEVICEID INT, USERID INT,CREATEDDATE DATETIME 
)

INSERT INTO 
@EventNotesTemp 
(
NOTES , EVENTID, EVENTTIME, DEVICEID,USERID,CREATEDDATE
)

SELECT
ISNULL(co.FirstName + ' ', '') + 
ISNULL(co.MiddleName + ' ', '') + 
ISNULL(co.LastName, '') + '-' +
convert(varchar,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),101) + ' ' +
convert(varchar,trackerpal.dbo.fnUtcToLocal(@AgencyID, en.CreatedDate),108) + ':' +
 + en.note ,
E.EVENTID,
E.EVENTTIME,
E.DEVICEID, 
EN.CreatedByID,
en.CreatedDate
FROM EVENTNOTE EN WITH (NOLOCK)
	LEFT JOIN #tempcourt2withnotes e ON en.DeviceID = e.DeviceID AND en.EventTime = e.EventTime AND en.EventID = e.EventID
	LEFT JOIN EventType et ON e.EventID = et.EventTypeID
	JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID AND (
		 (ota.activateDate< Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
		 and ota.DeActivateDate> Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0)))))
		or
		(ota.activateDate<Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
		and ota.DeActivateDate is null))
	LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID AND o.Deleted = 0
	left join operator co on co.userid= en.createdByID
WHERE
	(Convert(Datetime,(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
	DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	>= @StartDate 
	AND 
	Convert(DateTime,(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
	DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	<= @EndDate)
	and o.OffenderID = @OffenderID
	AND et.SO = 1 /*only the events that are available to So*/
	
	union 

SELECT
ISNULL(co.FirstName + ' ', '') + 
ISNULL(co.MiddleName + ' ', '') + 
ISNULL(co.LastName, '') + '-' +
convert(varchar,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),101 )+ ' ' +
convert(varchar,trackerpal.dbo.fnUtcToLocal(@AgencyID, an.CreatedDate),108 )+ ':' +
+ an.note,
E.EVENTID,
E.EVENTTIME,
E.DEVICEID, 
AN.CreatedByID,
an.CreatedDate
FROM ALARMNOTE AN WITH (NOLOCK)
	LEFT JOIN Alarm a ON A.ALARMID = AN.ALARMID
	LEFT JOIN #tempcourt2withnotes e ON 
	e.DeviceID = a.TrackerID 
		AND e.EventTime = a.EventTime 
		AND e.EventID = a.EventTypeID
	
	LEFT JOIN EventType et ON e.EventID = et.EventTypeID
	JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID AND (
		 (ota.activateDate< Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
		 and ota.DeActivateDate> Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0)))))
		or
		(ota.activateDate<Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
		and ota.DeActivateDate is null))
	
	LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID AND o.Deleted = 0
	left join operator co on co.userid= an.createdByID

WHERE
	(Convert(Datetime,(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
	DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	>= @StartDate 
	AND 
	Convert(DateTime,(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
	DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	<= @EndDate)
	and o.OffenderID = @OffenderID
	AND et.SO = 1 /*only the events that are available to So*/
 
/*end eventNotes*/

SELECT TOP 5000
	ISNULL(o.FirstName + ' ', '') + 
	ISNULL(o.MiddleName + ' ', '') + 
	ISNULL(o.LastName, '') AS 'Offender',
	ISNULL(so.FirstName + ' ', '') + 
	ISNULL(so.LastName, '') AS 'Officer',
	ag.Agency,
	        (trackerpal.dbo.fnUtcToLocal(@AgencyID, (Convert(DateTime,
                        (DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
                        DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0)))
                        )))) AS 'Event Time', 
	(
		CASE
			WHEN a.EventTypeID = 256 AND a.EventParameter > 0
			THEN et.AbbrevEventType + ' ' + CONVERT(nvarchar(4),a.EventParameter)
			ELSE et.AbbrevEventType
		END
	) AS 'Event Name',
	(
		CASE
			WHEN et.EventTypeGroupID = 5
			THEN gr.GeoRuleName 
			ELSE 'N/A'
		END
	) AS 'Geo Rule',
          (CASE WHEN e.Gpsvalid != 1 and e.GpsValidSatellites != 1 THEN 'Unavailable'
     ELSE e.Address END) AS 'Location',
CASE WHEN aa.AssignedDate IS NOT NULL THEN
trackerpal.dbo.fnUtcToLocal(@AgencyID,aa.AssignedDate) 
ELSE
trackerpal.dbo.fnUtcToLocal(@AgencyID,EN.CREATEDDATE) 
END as 'Accepted Date',
	case when oa.FirstName is null then
		ISNULL(op.FirstName + ' ', '') + 
		ISNULL(op.MiddleName + ' ', '') + 
		ISNULL(op.LastName, '')
	else
		ISNULL(oa.FirstName + ' ', '') + 
		ISNULL(oa.MiddleName + ' ', '') + 
		ISNULL(oa.LastName, '')
	END AS 'Operator',
	ISNULL(EN.nOTES,'') as Notes, 	
	ISNULL(ROUND(e.Latitude,5), 0) AS 'Latitude',
	ISNULL(ROUND(e.Longitude,5), 0) AS 'Longitude',
	ISNULL(e.GpsValid,0) as 'GpsValid',
	ISNULL(e.GpsValidSatellites,0) as 'GpsValidSatellites',
	--case when dbo.fnIsAlarmAutoCompleted(e.AlarmID) > 0 then 'Autocompleted Alarms' 
	--else 'Regular Alarms' end as 'IsAlarmsAutoCompleted',
	@StartDate as 'StartDateAgency',
	@EndDate as 'EndDateAgency',
	dbo.fnGetUtcOffset(@AgencyID) as 'utcoffset'	

FROM
	#tempcourt2withnotes e WITH (NOLOCK)
	LEFT JOIN EventType et ON e.EventID = et.EventTypeID
	LEFT JOIN Alarm a ON 
		e.DeviceID = a.TrackerID 
		AND e.EventTime = a.EventTime 
		AND e.EventID = a.EventTypeID
	JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID AND (
		 (ota.activateDate< Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
		 and ota.DeActivateDate> Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0)))))
		or
		(ota.activateDate<Convert(DateTime,
				(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
				DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
		and ota.DeActivateDate is null))
	LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID AND o.Deleted = 0
	LEFT JOIN Offender_Officer oo ON oo.OffenderID = o.OffenderID
	LEFT JOIN Officer so ON so.OfficerID = oo.OfficerID
	LEFT JOIN Agency ag ON ag.AgencyID = so.AgencyID
	LEFT JOIN AlarmAssignment aa on a.alarmId = aa.alarmid AND aa.AssignedDate = 
	(
		SELECT MAX(AssignedDate) FROM AlarmAssignment AAD WHERE aad.AlarmID = a.AlarmID and aad.alarmassignmentStatusID = 2
	) 
	and  aa.alarmassignmentStatusID = 2
	LEFT JOIN GeoRule gr ON gr.GeoRuleID = e.EventParameter
	LEFT JOIN @EventNotesTemp EN ON en.DeviceID = e.DeviceID AND en.EventTime = e.EventTime AND en.EventID = e.EventID
	LEFT JOIN operator oa on aa.AssignedToID = oa.userid
	LEFT JOIN operator op on EN.USERID = op.userid
WHERE
	(Convert(Datetime,(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
	DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	>= @StartDate 
	AND 
	Convert(DateTime,(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
	DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	<= @EndDate)
	and o.OffenderID = @OffenderID
    AND et.SO = 1 /*only the events that are available to So*/
ORDER BY e.EventTime asc, e.AlarmType
--IsAlarmsAutoCompleted,

Drop table #tempcourt2withnotes








GO
GRANT EXECUTE ON [ReportCourt2WithNotesDetailArchive] TO [db_dml]
GO

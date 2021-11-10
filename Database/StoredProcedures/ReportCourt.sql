USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[ReportCourt]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReportCourt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   ReportCourt.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:		 <Redmine #>      
 * Purpose:    Return Data for the Court Report               
 *
 * Modified By: R.Cole - 01/26/2010 SA_657 Convert Court Report
 *              Revise for conversion, readability, speed,
 *              and bring into standards compliance.
 * ******************************************************** */

CREATE PROCEDURE [ReportCourt] (
  @StartDate DATETIME,
  @EndDate DATETIME,
  @OffenderID INT,
  @AgencyID INT
)
AS

SET @StartDate = trackerpal.dbo.fnLocalToUtc(@AgencyID, @StartDate)
SET @EndDate = trackerpal.dbo.fnLocalToUtc(@AgencyID, @EndDate)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT e.*
INTO #tempcourt
FROM [dbo].[EventBuckets] e

WHERE e.EventDatetime >= @StartDate AND e.EventDatetime <= @EndDate
  AND e.Offenderid = @offenderid

SELECT TOP 5000
       ISNULL(o.FirstName + ' ', '') + ISNULL(o.MiddleName + ' ', '') + ISNULL(o.LastName, '') AS 'Offender',
       ISNULL(so.FirstName + ' ', '') + ISNULL(so.LastName, '') AS 'Officer',
       ag.Agency,
       (CASE WHEN a.EventTypeID = 256 AND a.EventParameter > 0
             THEN et.AbbrevEventType + ' ' + CONVERT(NVARCHAR(4),a.EventParameter)
             ELSE et.AbbrevEventType
        END) AS 'Alarm',
       (CASE WHEN et.EventTypeGroupID = 5
             THEN gr.GeoRuleName
             ELSE 'N/A'
        END) AS 'Geo Rule',
       (trackerpal.dbo.fnUtcToLocal(@AgencyID, (CONVERT(DATETIME, (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))))) AS 'Date',
       (CASE WHEN e.GpsValid > 0 OR e.eventid IN (176,177,178,179,180,181,182,184,185,192,193,194,195)
             THEN e.Address
             ELSE 'Unavailable'
        END) AS 'Location',
        ISNULL(ROUND(e.Latitude,5), 0) AS 'Latitude',
        ISNULL(ROUND(e.Longitude,5), 0) AS 'Longitude',
        ISNULL(e.GpsValid,0) AS 'GpsValid',
        ISNULL(e.GpsValidSatellites,0) AS 'GpsValidSatellites',
	      --case when dbo.fnIsAlarmAutoCompleted(e.AlarmID) > 0 then 'Autocompleted Alarms' 
	      --else 'Regular Alarms' end as 'IsAlarmsAutoCompleted',
	      @StartDate AS 'StartDateAgency',
	      @EndDate AS 'EndDateAgency',
	      dbo.fnGetUtcOffset(@AgencyID) AS 'utcoffset',
	      e.EventID,
	      o.offenderID
FROM #tempcourt e 
     --fnallevents () e
  LEFT JOIN EventType et ON e.EventID = et.EventTypeID
  LEFT JOIN Alarm a ON e.DeviceID = a.TrackerID
        AND e.EventTime = a.EventTime
        AND e.EventID = a.EventTypeID
  INNER JOIN OffenderTrackerActivation ota on ota.trackerid = e.DeviceID 
        AND (
                 (ota.activateDate< CONVERT(DATETIME,
                                (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,
                                DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
                 and ota.DeActivateDate> CONVERT(DATETIME,
                                (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,
                                DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0)))))
                or
                (ota.activateDate<CONVERT(DATETIME,
                                (DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,
                                DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))
                and ota.DeActivateDate IS NULL))
  LEFT JOIN Offender o ON o.OffenderID = ota.OffenderID AND o.Deleted = 0
  LEFT JOIN Offender_Officer oo ON oo.OffenderID = o.OffenderID
  LEFT JOIN Officer so ON so.OfficerID = oo.OfficerID
  LEFT JOIN Agency ag ON ag.AgencyID = so.AgencyID
  LEFT JOIN GeoRule gr ON gr.GeoRuleID = e.EventParameter
WHERE (CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000, DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))	>= @StartDate 
       AND CONVERT(DATETIME,(DATEADD(ms, (e.EventTime / CAST(10000 AS BIGINT)) % 86400000,	DATEADD(DAY, e.EventTime / CAST(864000000000 AS BIGINT) - 109207, 0))))	<= @EndDate)		
  AND o.OffenderID = @OffenderID
  AND et.SO = 1 /*only the events that are available to So*/

ORDER BY e.EventTime ASC, 
         e.AlarmType
--IsAlarmsAutoCompleted,

DROP TABLE #tempcourt
GO

GRANT EXECUTE ON [ReportCourt] TO [db_dml]
GO


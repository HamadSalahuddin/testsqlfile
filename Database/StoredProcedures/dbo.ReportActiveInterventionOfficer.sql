/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportActiveInterventionOfficer]

@Officerid int,
@Agencyid int

AS
Select
ofi.LastNAme+', '+ofi.firstname As 'Officer'
,o.Lastname+', '+o.Firstname AS OffenderName
,rpt.EventNAme
,dbo.fnUtcToLocal(@Agencyid,rpt.EventDateTime) AS 'Time'
,rpt.Address AS 'Location'
,rpt.GeoRule AS 'Rule'
,ag.Agency as 'Agency'

From dbo.rprtEventsBucket1 rpt
--JOIN Offender_Officer oo ON oo.Offenderid = rpt.offenderid
JOIN Offender o ON o.Offenderid = rpt.Offenderid
JOIN Officer ofi ON ofi.officerid = rpt.officerid
JOIN Agency ag ON ag.agencyid = rpt.agencyid
JOIN Timezone tz on tz.timezoneid = ag.timezoneid
--JOIN AgencyServices ags ON ags.Agencyid = ag.agencyid

WHERE dbo.fnUtcToLocal(@Agencyid,rpt.EventDateTime) BETWEEN DATEADD(hh,-24,CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@Agencyid,GETDATE())))))
AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@Agencyid,GETDATE()))))

AND rpt.officerid = @Officerid 
AND rpt.alarmtype > 1
ORDER BY OffenderNAme,rpt.EventDateTime


GO
GRANT EXECUTE ON [ReportActiveInterventionOfficer] TO [db_dml]
GO

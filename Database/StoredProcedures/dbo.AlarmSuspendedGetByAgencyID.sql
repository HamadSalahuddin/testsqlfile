/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmSuspendedGetByAgencyID]
	@AgencyID	INT
AS
	SELECT asd.AlarmSuspendedID,
           o.FirstName + ' ' + o.LastName as 'OffenderName', 
			ape.AlarmName as 'AlarmType',
		    dbo.fnGetGeoNamesFromZoneIDs(asd.ZoneIDs) as 'GeoRuleNames'
			,(CASE When asd.starttime Between ds.start AND ds.[end] And a.DaylightSavings = 1
				THEN DateAdd(mi,tz.DaylightUTCOFFSET,asd.starttime)
				ELSE DateAdd(mi,tz.UTCOFFSET,asd.starttime)END)AS 'StartTime'
			,(CASE When asd.endtime Between ds.start AND ds.[end] And a.DaylightSavings = 1
				THEN DateAdd(mi,tz.DaylightUTCOFFSET,asd.endtime)
				ELSE DateAdd(mi,tz.UTCOFFSET,asd.endtime)END)AS 'EndTime'
	FROM AlarmSuspended asd
	LEFT JOIN Offender o on asd.OffenderID = o.OffenderID
	LEFT JOIN AlarmProtocolEvent ape on asd.AlarmProtocolEventID = ape.GatewayEventID
   JOIN agency a On a.agencyid = asd.agencyid
   JOIN Timezone tz on tz.timezoneid = a.timezoneid
   JOIN DaylightSaving ds ON ds.[year] = DATEPART(yy,asd.StartTime)

	WHERE asd.AgencyID = @AgencyID AND
		asd.EndTime > GetDate() AND
        asd.Deleted = 0
GO
GRANT EXECUTE ON [AlarmSuspendedGetByAgencyID] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportOffenderAlarmNotesDetail]

	@StartDate		DATETIME,
	@EndDate		DATETIME,
	@AgencyID       INT,
    @OfficerID      INT,
	@OffenderID		INT,
	@TimeZoneOffset INT
	
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SELECT	TOP 5000
			--oon.note as 'OperatorNote',
			ag.Agency,
			a.OffenderID,
			ISNULL(officer.FirstName + ' ', '') + 
			ISNULL(officer.MiddleName + ' ', '') + 
			ISNULL(officer.LastName, '') AS 'OfficerName',
			ISNULL(o.FirstName + ' ', '') + 
			ISNULL(o.MiddleName + ' ', '') + 
			ISNULL(o.LastName, '') AS 'OffenderName',
			a.AlarmID, --a.AlarmTypeID, 
			DATEADD(mi, @TimeZoneOffset, (Convert(DateTime,a.EventDisplayTime))) as EventTime,
			et.longname as alarmName, 
			ISNULL(g.GeoRuleName, '') AS 'GeoRuleName',
			ISNULL(ROUND(a.Longitude,5), 0) AS 'Longitude',
			ISNULL(ROUND(a.Latitude,5), 0) AS 'Latitude',
			ISNULL(ap.Protocol, '') AS 'Protocol',
			an.Note,
            en.Note as 'EventNote',
			u.UserName,
			ut.UserType,
			DATEADD(mi, @TimeZoneOffset, (Convert(DateTime,an.CreatedDate))) as CreatedDate
		
	FROM	AlarmNote an
			INNER JOIN Alarm a on a.Alarmid = an.Alarmid 
			left join EventType et on et.EventTypeID = a.EventTypeID
			LEFT JOIN Offender o ON a.OffenderID = o.OffenderID
			left JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
			left join officer  on officer.OfficerID = oo.OfficerID 
			Left join Agency ag on ag.AgencyID = officer.AgencyID
			left Join [user] u on u.Userid = an.createdbyID
			--left join OffenderOperatorNote oon on  oon.OffenderID = a.OffenderID
			left Join userType ut on u.UserTypeid = ut.UserTypeID
			left join AlarmProtocol ap on a.EventTypeID = ap.EventTypeID and 
					ap.AgencyID = ag.AgencyID and 
					ap.OffenderID = a.OffenderID
			left join GeoRule g on g.GeoRuleID = a.EventParameter
			left join EventNote en on a.eventtypeid= en.EventId 
	WHERE	--a.AlarmID NOT IN (SELECT AlarmID FROM AlarmAcknowledgement)and
			(
				( @StartDate = 0 AND @EndDate = 0) 
				or
				(a.EventDisplayTime >= @StartDate AND a.EventDisplayTime <= @EndDate)
			)
			and
            (
				(@AgencyID= 0)
				or
				(o.AgencyID = @AgencyID)
			)
		    and
        	(
				(@OfficerID= 0)
				or
				(oo.OfficerID = @OfficerID)
			)
			and
			(
				(@OffenderID = 0)
				or
				(a.OffenderID = @OffenderID)
			)

	ORDER BY a.EventTime ASC, a.AlarmID ASC
GO
GRANT EXECUTE ON [ReportOffenderAlarmNotesDetail] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReportOffenderAlarmNotesDetail] TO [db_object_def_viewers]
GO

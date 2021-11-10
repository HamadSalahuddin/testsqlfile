/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportOffenderAlarmGetByStatusID]

	@StartDate		BIGINT,
	@EndDate		BIGINT,
	@StatusID		INT,
	@TimeZoneOffset INT,
	@SO				INT,
	@OPR			INT,
	@AgencyID       INT
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	-- all start/end dates, all event types, all offenders
SELECT	TOP 5000
         a.AlarmID,
			ag.Agency,
			ISNULL(ofcr.FirstName + ' ', '') + 
			ISNULL(ofcr.MiddleName + ' ', '') + 
			ISNULL(ofcr.LastName, '') AS 'OfficerName',
			ISNULL(o.FirstName + ' ', '') + 
			ISNULL(o.MiddleName + ' ', '') + 
			ISNULL(o.LastName, '') AS 'OffenderName',
			et.AbbrevEventType as EventName, 
			dbo.fxGetGeoRuleName(a.AlarmID) as 'GeoRuleName',
			DATEADD(mi,@TimeZoneOffSet,EventDisplayTime) AS Eventtime,
			CASE 
				WHEN a.Longitude <> 0 AND a.Latitude <> 0 THEN 
					CONVERT(VARCHAR,a.Latitude) + ', ' + CONVERT(VARCHAR,a.Longitude)
				ELSE 'unavailable'
         END AS Location,

           case when dbo.fnIsAlarmAutoCompleted(a.AlarmID) > 0 then 'Autocompleted Alarms' 
			else 'Regular Alarms' end as 'IsAlarmsAutoCompleted',
						ISNULL(aas.AlarmAssignmentStatusName,'New') AS 'Status',
			ISNULL(u.UserName,'') as 'AssignedByID',
			aas.AlarmAssignmentStatusName As 'Status',
         aa.AssignedByID,
         a.Address
	FROM	Alarm a 
			LEFT JOIN EventType et ON a.EventTypeID = et.EventTypeID
			JOIN OffenderTrackerActivation ota on ota.OffenderID = a.OffenderID and ota.TrackerID =a.TrackerID 
				AND ((ota.activateDate< a.EventDisplayTime and ota.DeActivateDate> a.EventDisplayTime) 
					OR (ota.activateDate<a.EventDisplayTime and ota.DeActivateDate is null))
			LEFT JOIN Offender o ON a.OffenderID = o.OffenderID
			LEFT JOIN Officer ofcr on (Select OfficerID from Offender_Officer where OffenderID = a.OffenderID) = ofcr.OfficerID
			LEFT JOIN Agency ag ON ofcr.AgencyID = ag.AgencyID
--			LEFT JOIN Gateway.Dbo.Events e ON 
--				e.DeviceID = a.TrackerID AND
--				e.EventTime = a.EventTime AND
--				e.EventID = a.EventTypeID
			LEFT JOIN GeoRule g ON g.GeoRuleID = a.EventParameter
			LEFT JOIN AlarmAssignment aa on aa.AlarmId = a.Alarmid and aa.AssignedDate = (select MAX(a2.AssignedDate) from alarmAssignment a2 where a2.Alarmid= a.Alarmid  ) 	
			LEFT JOIN AlarmAssignmentStatus aas on aa.AlarmAssignmentStatusID = aas. AlarmAssignmentStatusID
			LEFT JOIN [User] u on aa.AssignedByID= u.UserID
	WHERE	(
				(@StartDate = 0 AND @EndDate = 0) 
				OR
				(a.EventTime >= @StartDate AND a.EventTime <= @EndDate)
			)
			AND	
			(
				(
					(@StatusID=1)
					AND
					(aa.AlarmAssignmentStatusID IS NULL)
				)
				or
				(	
					(@StatusID < 0)
					OR
					(aa.AlarmAssignmentStatusID = @StatusID)
				)
			)
			AND
			(Agency IS NOT NULL)
			AND ((@SO<0) OR (et.SO=@SO))
			AND ((@OPR<0) OR (et.OPR=@OPR))
			AND ((@AgencyID=ag.AgencyID)OR(@AgencyID=0))
	ORDER BY IsAlarmsAutoCompleted,a.EventTime ASC, AlarmAssignmentStatusName ASC
GO
GRANT EXECUTE ON [ReportOffenderAlarmGetByStatusID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReportOffenderAlarmGetByStatusID] TO [db_object_def_viewers]
GO

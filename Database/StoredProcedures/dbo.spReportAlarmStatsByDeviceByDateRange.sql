/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spReportAlarmStatsByDeviceByDateRange] (
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime,
	@TimeZoneOffset int
)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN
	DELETE FROM tempAlarmStatsByDeviceByDateRange

	-- TrackerPal standard: All report @EndTime parameters are inclusive.  If time (not just date) is
	-- relevant, parameter must include seconds (but NOT milliseconds), and we add 1 second and use
	-- '<' on @EndDate comparisons to include correct data.  DK 5-9-07
	SET @EndDate = DATEADD(s, 1, @EndDate)

	-- Add TZ to the range.  We currently use the external code to output the range.  But if we ever
	-- output the range from the stored proc, then we will need to subtract TZ on the output data.
	-- DK 5-9-07
	SET @StartDate = DATEADD(minute, @TimeZoneOffset, @StartDate)
	SET @EndDate = DATEADD(minute, @TimeZoneOffset, @EndDate)

	INSERT INTO tempAlarmStatsByDeviceByDateRange
	SELECT
		ota.TrackerID,
		ota.OffenderID,t.AgencyID,ota.OfficerID,
		a.EventTypeID,a.AlarmTypeID,
		count(*) as 'total'
	FROM OffenderTrackerActivation ota
		LEFT JOIN Alarm a ON ota.TrackerID = a.TrackerID
			AND ((a.EventDisplayTime >= @StartDate AND a.EventDisplayTime < @EndDate)
					AND (a.EventDisplayTime >= ota.ActivateDate)
					AND (ota.DeActivateDate IS NULL OR a.EventDisplayTime < ota.DeActivateDate)
				)
		LEFT JOIN Tracker t ON ota.TrackerID = t.TrackerID

	-- WARNING: @StartDate comparison must be greater than or equal to include the start time in
	-- the data.  @EndDate comparison must be less than (not equal) to @EndDate and the passed
	-- in @EndDate be a "thru" value and then adjusted above to be a "to" value to correctly
	-- include all times at the end of the range in the data.  DK 5-9-07

	WHERE ota.ActivateDate < @EndDate AND (ota.DeActivateDate >= @StartDate OR ota.DeActivateDate IS NULL)
		AND (t.CreatedDate =
				(select MAX(CreatedDate)
				from Tracker t2
				where t2.TrackerID = t.TrackerID
					AND t2.CreatedDate < ota.ActivateDate)
			)
	GROUP BY ota.TrackerID, ota.OffenderID, t.AgencyID, ota.OfficerID, a.EventTypeID, a.AlarmTypeID
	ORDER BY ota.TrackerID, ota.OffenderID, t.AgencyID, ota.OfficerID, a.EventTypeID, a.AlarmTypeID


	-- Because we are doing a pivot query from rows to columns for each event type, the resulting table
	-- will have 1 identical row for each event type in the original tempAlarmStatsByDeviceByDateRange above.
	-- We use DISTINCT to eliminate the duplicates.  GROUP BY could also be used to accomplish the same things,
	-- but Pavel and I both think that DISTINCT will be more efficient.  DK 5-17-07
	SELECT DISTINCT aTemp.TrackerID,
		dp1.PropertyValue as 'SerialNumber',
		aTemp.OffenderID, o.FirstName + ' ' + o.MiddleName + ' ' + o.LastName as 'Offender',
		aTemp.AgencyID, ag.Agency,
		aTemp.OfficerID, oo.FirstName + ' ' + oo.MiddleName + ' ' + oo.LastName as 'Supv Officer',

		dbo.fnAlarmRereportAlarmStatsDevice(36,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'excl_violate_total (36)',
		dbo.fnAlarmRereportAlarmStatsDevice(37,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'excl_compliance_total (37)',
		dbo.fnAlarmRereportAlarmStatsDevice(280, aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'victim_prox_violate_total (280)',
		dbo.fnAlarmRereportAlarmStatsDevice(282, aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'victim_prox_alert_total (282)',
		dbo.fnAlarmRereportAlarmStatsDevice(281, aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'victim_prox_compliance_total (281)',
		dbo.fnAlarmRereportAlarmStatsDevice(44,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'incl_violate_total (44)',
		dbo.fnAlarmRereportAlarmStatsDevice(45,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'incl_compliance_total (45)',

		dbo.fnAlarmRereportAlarmStatsDevice(26,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'shutdown_pend_total (26)',
		dbo.fnAlarmRereportAlarmStatsDevice(25,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'batt_critical_total (25)',
		dbo.fnAlarmRereportAlarmStatsDevice(18,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'removed_extBatt_critical_total (18)',
		dbo.fnAlarmRereportAlarmStatsDevice(21,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'extBatt_timeout_total (21)',
      dbo.fnAlarmRereportAlarmStatsDevice(210,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'Batt_Crit-TP2 (210)',
		dbo.fnAlarmRereportAlarmStatsDevice(211,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'Batt_Crit_Esc-TP2 (211)',
		dbo.fnAlarmRereportAlarmStatsDevice(212,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'Shutdown_Now-TP2 (212)',
		dbo.fnAlarmRereportAlarmStatsDevice(65,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'strap_optical_total (65)',

		dbo.fnAlarmRereportAlarmStatsDevice(177,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'eBeaconMoved (177)',
		dbo.fnAlarmRereportAlarmStatsDevice(178,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'eBeaconOpened (178)',
		dbo.fnAlarmRereportAlarmStatsDevice(179,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'eBeacon_Sequence_Invalid (179)',
		dbo.fnAlarmRereportAlarmStatsDevice(182,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'eBeaconBatCrit (180)',
		dbo.fnAlarmRereportAlarmStatsDevice(194,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'eArrestViol (194)',
		dbo.fnAlarmRereportAlarmStatsDevice(195,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'eArrestComply (195)',

		dbo.fnAlarmRereportAlarmStatsDevice(256, aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'noevent_timeout_total (256)',
		dbo.fnAlarmRereportAlarmStatsDevice(258, aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'noevent_timeout_escalate_total (258)',
		dbo.fnAlarmRereportAlarmStatsDevice(257, aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'comm_resumed_total (257)',

		dbo.fnAlarmRereportAlarmStatsDevice(5,   aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'removed_shutdown_pend_total (5)',
		dbo.fnAlarmRereportAlarmStatsDevice(3,   aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'power_down_total (3)',
		dbo.fnAlarmRereportAlarmStatsDevice(1,   aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'power_up_total (1)',

		dbo.fnAlarmRereportAlarmStatsDevice(-1,  aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'misc_alarms',
		dbo.fnASAPReportsMiscAlarmTypesAlarmStatsDevice(aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'misc_alarms_types',
		dbo.fnAlarmRereportAlarmStatsDevice(0,   aTemp.TrackerID, aTemp.AgencyID, aTemp.OfficerID, aTemp.OffenderID) as 'total'
	FROM tempAlarmStatsByDeviceByDateRange aTemp
		-- LEFT JOIN is used instead of a natural join so that in case there are any devices that don't
		-- have these values set we won't lose the device from the report.  DK 5-17-07
		LEFT JOIN Gateway.dbo.DeviceProperties dp1 ON aTemp.TrackerID = dp1.DeviceID AND dp1.PropertyID = '8012'
		LEFT JOIN Offender o on aTemp.OffenderID = o.OffenderID
		LEFT JOIN Agency ag on aTemp.AgencyID = ag.AgencyID
		LEFT JOIN Officer oo on aTemp.OfficerID = oo.OfficerID
	ORDER BY aTemp.TrackerID,dp1.PropertyValue,aTemp.OffenderID,'Offender',aTemp.AgencyID,Agency,aTemp.OfficerID,'Supv Officer'


	-- Clean up section
	-- To be safe, don't clear here, since its data is returned in a stream.  DK 5-9-07
	-- DELETE FROM tempAlarmStatsByDeviceByDateRange
END

GO
GRANT VIEW DEFINITION ON [spReportAlarmStatsByDeviceByDateRange] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [spReportAlarmStatsByDeviceByDateRange] TO [db_dml]
GO

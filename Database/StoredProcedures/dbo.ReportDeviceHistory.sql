/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportDeviceHistory]

	@StartDate		DateTime,
	@EndDate		DateTime,
	@TimeZoneOffset INT,
	@AgencyID		INT

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT	DISTINCT TOP 5000  
		t.TrackerID, 
		d.name as DeviceName,
		t.TrackerNumber, 
--		isnull(P.propertyValue,'') AS PhoneNumber,
--		isnull(P2.propertyValue,'') AS PhoneNumber1,
--		isnull(d.PhoneNumber,'') AS PhoneNumber2,
		a.Agency,
		ISNULL(officer.FirstName, '')+ ' '+
		ISNULL(officer.MiddleName, '')+' '+
		ISNULL(officer.LastName, '') AS 'officerName',
		ISNULL(o.FirstName, '')+ ' '+
		ISNULL(o.MiddleName, '')+' '+
		ISNULL(o.LastName, '') AS 'OffenderName',
		case when ota.ActivateDate >= @StartDate
		then (DATEADD ( mi, @TimeZoneOffset, (Convert(DateTime,ota.ActivateDate))))
		else null END as ActivateDate,
		case when ota.DeActivateDate <= @EndDate
		then (DATEADD ( mi, @TimeZoneOffset, (Convert(DateTime,ota.DeActivateDate))))
		else null END as DeActivateDate
		FROM	OffenderTrackerActivation ota
		LEFT JOIN Offender o ON (ota.OffenderID = o.OffenderID AND o.Deleted = 0)
	        LEFT JOIN officer  on officer.OfficerID = ota.OfficerID
        	LEFT JOIN Agency a ON a.AgencyID = o.AgencyID
	        LEFT JOIN Tracker t on ota.TrackerID =t.TrackerID
        	LEFT JOIN Gateway.dbo.Devices d on t.TrackerID = d.DeviceID
--	        LEFT JOIN Gateway.dbo.deviceProperties P ON P.deviceid =t.TrackerID  and P.propertyID='8203'
--        	LEFT JOIN Gateway.dbo.deviceProperties P2 ON P2.deviceid =t.TrackerID  and P2.propertyID='8206'
		WHERE	--t.Deleted = 0 AND
			(	
				d.Address!=''
			)
		and
			(
--				( @StartDate = 0 AND @EndDate = 0) 
--				or
				(
					ota.ActivateDate >= @StartDate AND
					ota.ActivateDate <= @EndDate
				)
				or
				(
					ota.DeActivateDate >= @StartDate AND
					ota.DeActivateDate <= @EndDate
				)

			)
		and
			(
				a.AgencyID = @AgencyID
			)
		ORDER BY 	t.TrackerNumber
GO
GRANT VIEW DEFINITION ON [ReportDeviceHistory] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [ReportDeviceHistory] TO [db_dml]
GO
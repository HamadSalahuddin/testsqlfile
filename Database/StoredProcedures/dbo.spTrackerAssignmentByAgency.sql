/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spTrackerAssignmentByAgency]
@StartDate Datetime,
@EndDate Datetime,
@Agencyid INT
AS
SELECT DISTINCT
	 a.Agency,
	 convert(varchar,DateADD(mi,-360,a.CreatedDate),101)AS 'AgencyCreateDate',
	 t.TrackerID,
	 t.TrackerNumber,
     dp5.PropertyValue AS 'SerialNumber',
	 CONVERT(VArchar(25),DATEADD(mi,tz.DaylightUtcOffset,t.CreatedDate),101) AS 'Assigned Date',
	 CONVERT(VArchar(25),DATEADD(mi,tz.DaylightUtcOffset,t.ModifiedDate),101) AS 'Modified Date',
     CASE(t.deleted)
     When 1 then 'Unassigned'
     ELSE 'Assigned'
	 END AS 'Assignment Status',
	 t.RMAID,
	 CASE(tb.Status) When 2 Then 'NonBillable'
     ELSE 'Billable' END AS 'Billing',
	 CASE(t.IsDemo) WHEN 1 Then 'Demo'
     ELSE 'Non-Demo' END AS 'Demo'
	
FROM Tracker t
JOIN Agency a ON t.AgencyID = a.AgencyID
LEFT JOIN TrackerBillable tb ON t.BillableID = tb.TrackerBillableID
JOIN timezone tz ON a.timezoneid = tz.timezoneid
JOIN Gateway.dbo.DeviceProperties dp5 ON t.TrackerID = dp5.DeviceID AND dp5.PropertyID = '8012'

WHERE 
	  (DATEADD(mi,tz.DaylightUtcOffset,t.CreatedDate) < @EndDate) AND
	  (DATEADD(mi,tz.DaylightUtcOffset,t.ModifiedDate) > @StartDate OR DATEADD(mi,tz.DaylightUtcOffset,t.ModifiedDate) IS NULL 
OR t.deleted = 0) AND t.Agencyid = @Agencyid


ORDER BY A.Agency, 'Assigned Date'


GO
GRANT EXECUTE ON [spTrackerAssignmentByAgency] TO [db_dml]
GO
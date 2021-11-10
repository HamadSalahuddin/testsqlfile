USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTrackerAssignment]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTrackerAssignment]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTrackerAssignment.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     <Redmine #>      
 * Purpose:    Populate the TrackerAssignment Report               
 *
 * Modified By: R.Cole - 11/01/2009: Added Timestamp's
 *              R.Cole - 07/02/2010: Refactor SProc and 
 *                Added OriginalShipment Flag 
 * ******************************************************** */
CREATE PROCEDURE [spTrackerAssignment] (
    @StartDate Datetime,
    @EndDate Datetime
)
AS

SELECT DISTINCT Agency.SFDCAccount AS 'SFDCACCT#',
       Agency.AgencyID,
	     Agency.Agency,
	     CONVERT(VARCHAR,DATEADD(mi, -360, Agency.CreatedDate),101) AS 'AgencyCreateDate',
	     Tracker.TrackerID,
	     Tracker.TrackerNumber,
       gwDeviceProperties.PropertyValue AS 'SerialNumber',
	     DATEADD(mi, TimeZone.DaylightUtcOffset, Tracker.CreatedDate) AS 'Assigned Date',
	     DATEADD(mi, TimeZone.DaylightUtcOffset, Tracker.ModifiedDate) AS 'Modified Date',
       CASE WHEN Tracker.Deleted = 1 THEN 'Unassigned' ELSE 'Assigned' END AS 'Assignment Status',
	     Tracker.RMAID,
	     CASE WHEN TrackerBillable.[Status] = 2 THEN 'NonBillable' ELSE 'Billable' END AS 'Billing',
	     CASE WHEN Tracker.IsDemo = 1 THEN 'Demo' ELSE 'Non-Demo' END AS 'Demo',
	     CASE WHEN Tracker.CreatedByID IN (4326, 6853) THEN 1 ELSE 0 END AS 'OriginalShipment'	
FROM Tracker 
  INNER JOIN Agency ON Tracker.AgencyID = Agency.AgencyID
  LEFT JOIN TrackerBillable ON Tracker.BillableID = TrackerBillable.TrackerBillableID
  INNER JOIN TimeZone ON Agency.TimeZoneID = TimeZone.TimeZoneID
  INNER JOIN Gateway.dbo.DeviceProperties gwDeviceProperties ON Tracker.TrackerID = gwDeviceProperties.DeviceID
         AND gwDeviceProperties.PropertyID = '8012'  
WHERE (DATEADD(mi, TimeZone.DaylightUtcOffset, Tracker.CreatedDate) < @EndDate) 
  AND (DATEADD(mi, TimeZone.DaylightUtcOffset, Tracker.ModifiedDate) > @StartDate 
       OR DATEADD(mi, TimeZone.DaylightUtcOffset, Tracker.ModifiedDate) IS NULL 
       OR Tracker.Deleted = 0)
ORDER BY 
    Agency.Agency,
    'Assigned Date'
GO

GRANT EXECUTE ON [spTrackerAssignment] TO [db_dml]
GO

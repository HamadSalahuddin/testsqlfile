/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportDeviceActions]
       @ActionTypeID           int,
        @StartDate              DateTime,
        @EndDate                DateTime,
        @TimeZoneOffset			INT,
        @OfficerID				INT,
        @AgencyID				INT,
        @OffenderID				INT
       

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
select distinct	TOP 5000 isnull(offi.FirstName +' '+offi.LastName ,op.FirstName+' '+op.LastName) as username,
		at.TrackerActionTypeName,
		ISNULL(o.FirstName + ' ', '') + 
		ISNULL(o.MiddleName + ' ', '') + 
		ISNULL(o.LastName, '') AS 'OffenderName',
	    CONVERT(varchar, dateaDD(mi, @TimeZoneOffset, (Convert(DateTime, a.TrackerActionDateTime))), 101)
	    + ' ' +  CONVERT(varchar, dateaDD(mi, @TimeZoneOffset, (Convert(DateTime, a.TrackerActionDateTime))), 108)
	    as   TrackerActionDateTime
 from [fnAllTrackerAction]() a
left join [User] u on u.UserID = a.createdByID
left join Operator op on u.UserID = op.UserID
left join Officer offi on u.UserID = offi.UserID
left join TrackerActionType at on at.trackerActionTypeID= a.trackerActionTypeID
left JOIN OffenderTrackerActivation ota ON ota.TrackerID = a.TrackerID 
		AND((ota.activateDate<= a.TrackerActionDateTime AND ota.DeActivateDate>= a.TrackerActionDateTime) 
			OR (ota.activateDate<=a.TrackerActionDateTime AND ota.DeActivateDate IS NULL))
left join offender o on o.offenderID= ota.OffenderID
left join offender_officer oo on o.OffenderId= oo.OffenderId 
  WHERE
                (
                        (@StartDate = 0 AND @EndDate = 0)
                        OR
                        (
                                (a.TrackerActionDateTime >= @StartDate)
                                AND
                                (a.TrackerActionDateTime <= @EndDate)
                        )
                )
				AND
				(
					(@OffenderID<=0)
					OR
					(o.OffenderID=@OffenderID)
				)
				AND
				(
					(@AgencyID<=0)
					OR
					(o.AgencyID=@AgencyID)
				)
				AND
				(
					(@OfficerID<=0)
					OR
					(oo.OfficerID=@OfficerID)
				)
				AND
				(
					(@ActionTypeID<=0)
					or
					(at.TrackerActionTypeID = @ActionTypeID)
				)
order by TrackerActionDateTime

GO
GRANT EXECUTE ON [ReportDeviceActions] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReportDeviceActions] TO [db_object_def_viewers]
GO

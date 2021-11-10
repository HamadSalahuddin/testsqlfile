/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmGetByEventTypeIDtest]


	@StartDate		BIGINT,
	@EndDate		BIGINT,
	@EventTypeID	INT,
	@SO				INT,
	@OPR			INT,
	@EventTypeGroupID int,
	@UserID INT = -1, 
	@RoleID INT = -1

AS
Select * 
INTO #tempalarmbeteventtype
From alarm
Where eventtime > = @StartDate And eventtime <= @Enddate



	
IF @RoleID <> 6
	BEGIN
		SELECT
                        a.EventParameter,
			a.AlarmID, 
			a.AlarmType AS 'AlarmTypeID', 
			a.EventTime,
			ISNULL(a.AlarmAssignmentStatusID,0) AS 'AlarmAssignmentStatusID',
			ISNULL(a.AlarmAssignmentStatusName,'Unassigned') AS 'AlarmAssignmentStatusName',
		--	(
		--		CASE
		--			WHEN a.EventTypeID = 256 AND a.EventParameter > 0
		--			THEN et.AbbrevEventType + ' ' + CONVERT(nvarchar(4),a.EventParameter)
		--			ELSE et.AbbrevEventType
		--		END
		--	) AS 'EventName', 
			a.EventName,
			ISNULL(ROUND(a.Longitude,5), 0) AS 'Longitude',
			ISNULL(ROUND(a.Latitude,5), 0) AS 'Latitude',
			ISNULL(a.Address, CONVERT(nvarchar(9),ISNULL(ROUND(a.Latitude,5), 0))+', '+CONVERT(nvarchar(9),ISNULL(ROUND(a.Longitude,5), 0)) ) AS 'Address',
		--	ISNULL(o.FirstName + ' ', '') + 
		--	ISNULL(o.MiddleName + ' ', '') + 
		--	ISNULL(o.LastName, '') AS 'OffenderName',
			a.OffenderName,
			a.OffenderID,
			(SELECT COUNT (*) FROM AlarmNote WHERE AlarmID = a.AlarmID) AS 'NoteCount',
				ISNULL(a.GpsValid,0) AS 'GpsValid',
				ISNULL(a.GpsValidSatellites,0) AS 'GpsValidSatellites',
			a.DeviceID, 
			a.EventID,
			(
				CASE
					WHEN a.EventTypeGroupID =5
					THEN a.GeoRule
					ELSE 'N/A'
				END
			) AS 'GeoRule'
       
		FROM
--			[fnEvents] ( [dbo].[ConvertLongToDate]( @StartDate ) , [dbo].[ConvertLongToDate]( @EndDate ) ) a
#tempalarmbeteventtype e		
JOIN (SELECT * from rprteventsbucket1 WITH (NOLOCK)
      UNION ALL
      SELECT * From rprteventsbucket2 WITH (NOLOCK)) a ON a.alarmid = e.alarmid
		WHERE
			a.AlarmType > 1 
			AND a.AlarmID NOT IN (SELECT AlarmID FROM AlarmAcknowledgement)
			AND (
				(@StartDate = 0 AND @EndDate = 0) 
				OR
				(a.EventTime >= @StartDate AND a.EventTime <= @EndDate)
			)
			AND	((@EventTypeID<0) OR (a.EventID = @EventTypeID))
			AND ((@SO<0) OR (a.SO=@SO))
			AND ((@OPR<0) OR (a.OPR=@OPR))
			AND	(
				(@EventTypeGroupID < 0)
				OR
				(a.EventTypeGroupID = @EventTypeGroupID )
			)
		ORDER BY
			a.EventTime DESC, a.AlarmType DESC 
	END
ELSE
BEGIN
		SELECT
			a.AlarmID, 
			a.AlarmType AS 'AlarmTypeID', 
			a.EventTime,
			ISNULL(a.AlarmAssignmentStatusID,0) AS 'AlarmAssignmentStatusID',
			ISNULL(a.AlarmAssignmentStatusName,'Unassigned') AS 'AlarmAssignmentStatusName',
		--	(
		--		CASE
		--			WHEN a.EventTypeID = 256 AND a.EventParameter > 0
		--			THEN et.AbbrevEventType + ' ' + CONVERT(nvarchar(4),a.EventParameter)
		--			ELSE et.AbbrevEventType
		--		END
		--	) AS 'EventName', 
			a.EventName,
			ISNULL(ROUND(a.Longitude,5), 0) AS 'Longitude',
			ISNULL(ROUND(a.Latitude,5), 0) AS 'Latitude',
			ISNULL(a.Address, CONVERT(nvarchar(9),ISNULL(ROUND(a.Latitude,5), 0))+', '+CONVERT(nvarchar(9),ISNULL(ROUND(a.Longitude,5), 0)) ) AS 'Address',
		--	ISNULL(o.FirstName + ' ', '') + 
		--	ISNULL(o.MiddleName + ' ', '') + 
		--	ISNULL(o.LastName, '') AS 'OffenderName',
			a.OffenderName,
			a.OffenderID,
			(SELECT COUNT (*) FROM AlarmNote WHERE AlarmID = a.AlarmID) AS 'NoteCount',
			ISNULL(a.GpsValid,0) AS 'GpsValid',
			ISNULL(a.GpsValidSatellites,0) AS 'GpsValidSatellites',
			a.DeviceID, 
			a.EventID,
			(
				CASE
					WHEN a.EventTypeGroupID =5
					THEN a.GeoRule
					ELSE 'N/A'
				END
			) AS 'GeoRule'
		
		FROM
--			[fnEvents] ( [dbo].[ConvertLongToDate]( @StartDate ) , [dbo].[ConvertLongToDate]( @EndDate ) ) a
#tempalarmbeteventtype e
JOIN (SELECT * from rprteventsbucket1 WITH (NOLOCK)
      UNION ALL
      SELECT * From rprteventsbucket2 WITH (NOLOCK)) a ON a.alarmid = e.alarmid
		WHERE
			a.AlarmType > 1 
			AND a.AlarmID NOT IN (SELECT AlarmID FROM AlarmAcknowledgement)
			AND (
				(@StartDate = 0 AND @EndDate = 0) 
				OR
				(a.EventTime >= @StartDate AND a.EventTime <= @EndDate)
			)
			AND	((@EventTypeID<0) OR (a.EventID = @EventTypeID))
			AND ((@SO<0) OR (a.SO=@SO))
			AND ((@OPR<0) OR (a.OPR=@OPR))
			AND	(
				(@EventTypeGroupID < 0)
				OR
				(a.EventTypeGroupID = @EventTypeGroupID )
			)
			AND a.AgencyID IN (SELECT AgencyID FROM Agency WHERE DistributorID IN (SELECT DistributorID FROM DistributorEmployee WHERE UserId = @UserId ) )
		ORDER BY
			a.EventTime DESC, a.AlarmType DESC 
	END
Drop table #tempalarmbeteventtype



GO
GRANT EXECUTE ON [AlarmGetByEventTypeIDtest] TO [db_dml]
GO

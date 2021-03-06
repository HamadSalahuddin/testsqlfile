/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerGetBySearch]
        @AgencyID               int = 0,
        @GatewayPort    varchar(10),
        @GatewayIp              varchar(20),
	@TrackerID              varchar(10) = '',
        @TrackerNumber  varchar(32) = '',
        @TrackerPhone   varchar(32) = '',
	@RoleID int = -1,
        @UserID int = -1

AS

DECLARE @AgencyAssigned int, @OffenderAssigned int, @Activated int, @Unassigned int, @Rma int
SET @AgencyAssigned = 1
SET @OffenderAssigned = 2
SET @Activated = 3
SET @Unassigned = 4
SET @Rma = 4

	SELECT 
        t.TrackerID,
        t.TrackerNumber + CASE WHEN t.IsDemo = 1 then ' (Demo)' else '' END AS 'TrackerNumber',
        a.Agency,
        d.name as DeviceName,
        CASE
                WHEN dp3.PropertyValue = '' THEN '0'
                WHEN dp3.PropertyValue IS NULL THEN '0'
                ELSE dp3.PropertyValue
        END AS 'DeviceFirmware',
        CASE
                WHEN t.RmaID IS NOT NULL THEN @Rma
                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN @Activated
                WHEN ta.TrackerAssignmentTypeID = 1 THEN @OffenderAssigned
                WHEN t.CreatedDate < GETDATE() THEN @AgencyAssigned
                ELSE @Unassigned
        END AS 'DeviceStatus',
        DATEADD( mi, dbo.fnGetUtcOffset(a.AgencyID),
                CASE
                        WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN ota.ActivateDate
                        WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NOT NULL THEN ota.DeactivateDate
                        WHEN ta.AssignmentDate IS NOT NULL THEN ta.AssignmentDate
                        -- WHEN ta.TrackerAssignmentTypeID = 1 THEN ta.AssignmentDate
                        WHEN t.CreatedDate < GETDATE() THEN t.ModifiedDate
                END
        ) AS 'StatusModifiedDate',
        CASE
                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN u1.UserName
                WHEN ta.TrackerAssignmentTypeID = 1 THEN u2.UserName
                WHEN t.CreatedDate < GETDATE() THEN u3.UserName
        END AS 'StatusModifiedBy',
        CASE
                WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(o.FirstName, '')+' '+ISNULL(o.MiddleName, '')+' '+ISNULL(o.LastName, '')
                ELSE ''
        END AS 'OffenderName',
        CASE
                WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(officer.FirstName, '')+' '+ISNULL(officer.MiddleName, '')+' '+ISNULL(officer.LastName, '')
                ELSE ''
        END AS 'officerName'

--        isnull(P.propertyValue,'') AS PhoneNumber,
--        isnull(P2.propertyValue,'') AS PhoneNumber1,
--        isnull(d.PhoneNumber,'') AS PhoneNumber2
FROM
        Tracker t
        LEFT JOIN Agency a ON t.AgencyID = a.AgencyID AND a.deleted = 0
        LEFT JOIN Gateway.dbo.Devices d ON t.TrackerID = d.DeviceID
        LEFT JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID
                AND ta.TrackerAssignmentID = (
                        SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment TA WHERE TA.TrackerID = t.TrackerID
                )
        LEFT JOIN Offender o ON o.OffenderID = ta.OffenderID AND o.Deleted = 0 AND ta.TrackerAssignmentTypeID = 1
        LEFT JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
        LEFT JOIN officer ON officer.OfficerID = oo.OfficerID
        LEFT JOIN Gateway.dbo.deviceProperties P ON P.deviceid =t.TrackerID and P.propertyID='8203'
        LEFT JOIN Gateway.dbo.deviceProperties P2 ON P2.deviceid =t.TrackerID and P2.propertyID='8206'
        left join Gateway.dbo.DeviceProperties dp1 on dp1.DeviceID = d.DeviceID and dp1.propertyID='8410'
        left join Gateway.dbo.DeviceProperties dp2 on dp2.DeviceID = d.DeviceID and dp2.propertyID='8411'
        LEFT JOIN Gateway.dbo.DeviceProperties dp3 on dp3.DeviceID = d.DeviceID and dp3.propertyID='8016'
                AND ta.AssignmentDate = (
                        SELECT MAX(AssignmentDate) FROM TrackerAssignment TA WHERE TA.TrackerID = t.TrackerID
                )
        LEFT JOIN OffenderTrackerActivation ota ON ota.TrackerID = t.TrackerID
                AND ota.ActivateDate = (
                        SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WHERE OTA.TrackerID = t.TrackerID
                )
        LEFT JOIN [User] u1 ON u1.UserID = ota.ModifiedByID
        LEFT JOIN [User] u2 ON u2.UserID = ta.CreatedBy
        LEFT JOIN [User] u3 ON u3.UserID = t.ModifiedByID 
        
WHERE
        (
                (@AgencyID = 0)
                OR
                (t.AgencyID = @AgencyID)
        )
		AND
		(
				((@RoleID = 6) AND (a.DistributorID IN (	SELECT	de.DistributorID 
					FROM	distributoremployee de
					WHERE	de.UserID=@UserID)))
				OR (@RoleID <> 6)
		)

        AND
        (
                (LEN(@TrackerID) <= 0)
                OR
                (CAST(t.TrackerID AS VARCHAR(20)) LIKE '%' + @TrackerID + '%')
        )
        AND
        (
                (LEN(@TrackerNumber) <= 0)
                OR
                (t.TrackerNumber LIKE '%' + @TrackerNumber + '%')
                OR
                (
                        (PATINDEX('%demo%', @TrackerNumber) > 0)
                        AND
                        (t.IsDemo = 1)
                )
        )
        AND
        (
                (LEN(@TrackerPhone) <= 0)
                OR
                (CASE
                        WHEN (p.propertyValue IS NULL OR p.propertyValue = '') AND (p2.propertyValue IS NULL OR p2.propertyValue = '') THEN d.PhoneNumber
                        WHEN (p.propertyValue IS NULL OR p.propertyValue = '') THEN p2.propertyValue
                        ELSE p.propertyValue
                END
                LIKE '%' + @TrackerPhone + '%')
        )
        AND
        (
                (o.OffenderID IS NOT NULL)
                OR
                (
                        (dp1.PropertyValue = @GatewayIp)
                        AND
                        (dp2.PropertyValue = @GatewayPort)
                )
        )
        AND t.Deleted = 0
	ORDER BY
        a.Agency, t.TrackerNumber

GO
GRANT EXECUTE ON [TrackerGetBySearch] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [TrackerGetBySearch] TO [db_object_def_viewers]
GO

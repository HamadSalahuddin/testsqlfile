/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerGetGridInfo]
        @AgencyID               int,
        @GatewayPort    varchar(10),
        @GatewayIp              varchar(20),
        @StatusSort             int = 0,
	@RoleID int = -1,
        @UserID int = -1
AS

DECLARE @AgencyAssigned int, @OffenderAssigned int, @Activated int, @Unassigned int, @Rma int
SET @AgencyAssigned = 1
SET @OffenderAssigned = 2
SET @Activated = 3
SET @Unassigned = 0
SET @Rma = 4

IF (@StatusSort = 0)
BEGIN
        SELECT DISTINCT
                t.TrackerID, 
                t.TrackerNumber +   
                        CASE 
                                WHEN t.IsDemo = 1 then ' (Demo)' else ''
                        END AS 'TrackerNumber', 
                a.Agency,
                d.[Name] AS 'DeviceName',
                CASE
                        WHEN dp3.PropertyValue = '' THEN '0'
                        WHEN dp3.PropertyValue IS NULL THEN '0'
                        ELSE dp3.PropertyValue
                END AS 'DeviceFirmware',
                CASE 
                        WHEN t.RmaID IS NOT NULL THEN @Rma
                        WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL 
				AND ta.TrackerAssignmentTypeID = 1 THEN 
				@Activated
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
--                ISNULL(P.propertyValue,'') AS PhoneNumber,
--                ISNULL(P2.propertyValue,'') AS PhoneNumber1,
--                ISNULL(d.PhoneNumber,'') AS PhoneNumber2
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
--                LEFT JOIN Gateway.dbo.deviceProperties P ON P.deviceid =t.TrackerID and P.propertyID='8203'
--                LEFT JOIN Gateway.dbo.deviceProperties P2 ON P2.deviceid =t.TrackerID and P2.propertyID='8206'
                LEFT JOIN Gateway.dbo.DeviceProperties dp1 on dp1.DeviceID = d.DeviceID and dp1.propertyID='8410'
                LEFT JOIN Gateway.dbo.DeviceProperties dp2 on dp2.DeviceID = d.DeviceID and dp2.propertyID='8411'
                LEFT JOIN Gateway.dbo.DeviceProperties dp3 on dp3.DeviceID = d.DeviceID and dp3.propertyID='8016'       
		LEFT JOIN OffenderTrackerActivation ota ON ota.TrackerID = t.TrackerID 
                        AND ota.ActivateDate = (
				SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WHERE OTA.TrackerID = t.TrackerID
			)
                LEFT JOIN [User] u1 ON u1.UserID = ota.ModifiedByID
                LEFT JOIN [User] u2 ON u2.UserID = ta.CreatedBy
                LEFT JOIN [User] u3 ON u3.UserID = t.ModifiedByID
                LEFT JOIN  distributoremployee de on a.DistributorID = de.DistributorID
        WHERE
                t.Deleted = 0 
                AND (
			(@AgencyID = 0 )
			OR 
			(a.AgencyID = @AgencyID)
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
                        (o.OffenderID IS NOT NULL)
                        OR
                        (
				(dp1.PropertyValue = @GatewayIp)
				AND 
				(dp2.PropertyValue = @GatewayPort)
			)
                )
                AND (
                  ( @RoleID <> 6 )
	        or
		  ( de.UserID = @UserID)
                )
        ORDER BY 
                a.Agency, 'TrackerNumber'
END

IF (@StatusSort =-1)
BEGIN
        SELECT DISTINCT
                t.TrackerID, 
                t.TrackerNumber +   
                        CASE 
                                WHEN t.IsDemo = 1 then ' (Demo)' else ''
                        END AS 'TrackerNumber',
                a.Agency,
                d.[Name] AS 'DeviceName',
                CASE
                        WHEN dp3.PropertyValue = '' THEN '0'
                        ELSE dp3.PropertyValue
                END AS 'DeviceFirmware',
                CASE 
                        WHEN t.RmaID IS NOT NULL THEN @Rma
                        WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL AND ta.TrackerAssignmentTypeID = 1 THEN @Activated
                        WHEN ta.TrackerAssignmentTypeID = 1 THEN @OffenderAssigned
                        WHEN t.CreatedDate < GETDATE() THEN @AgencyAssigned
                        ELSE @Unassigned
        END AS 'DeviceStatus',
                DATEADD( mi, dbo.fnGetUtcOffset(a.AgencyID),
                        CASE
                                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN ota.ActivateDate
                                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NOT NULL THEN ota.DeactivateDate
                                WHEN ta.AssignmentDate IS NOT NULL THEN ta.AssignmentDate
--                              WHEN ta.TrackerAssignmentTypeID = 1 THEN ta.AssignmentDate
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
--                ISNULL(P.propertyValue,'') AS PhoneNumber,
--                ISNULL(P2.propertyValue,'') AS PhoneNumber1,
--                ISNULL(d.PhoneNumber,'') AS PhoneNumber2
        FROM
                Tracker t
                LEFT JOIN Agency a ON t.AgencyID = a.AgencyID AND a.deleted=0
                LEFT JOIN Gateway.dbo.Devices d ON t.TrackerID = d.DeviceID
                LEFT JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID
                        AND ta.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment TA WHERE TA.TrackerID = t.TrackerID)
                LEFT JOIN Offender o ON o.OffenderID = ta.OffenderID AND o.Deleted = 0 AND ta.TrackerAssignmentTypeID = 1
                LEFT JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
                LEFT JOIN officer ON officer.OfficerID = oo.OfficerID 
--                LEFT JOIN Gateway.dbo.deviceProperties P ON P.deviceid =t.TrackerID  and P.propertyID='8203'
--                LEFT JOIN Gateway.dbo.deviceProperties P2 ON P2.deviceid =t.TrackerID  and P2.propertyID='8206'
                LEFT JOIN Gateway.dbo.DeviceProperties dp1 on dp1.DeviceID = d.DeviceID and  dp1.propertyID='8410'
                LEFT JOIN Gateway.dbo.DeviceProperties dp2 on dp2.DeviceID = d.DeviceID and dp2.propertyID='8411'
                LEFT JOIN Gateway.dbo.DeviceProperties dp3 on dp3.DeviceID = d.DeviceID and dp3.propertyID='8016'       
                LEFT JOIN OffenderTrackerActivation ota ON ota.TrackerID = t.TrackerID 
                        AND ota.ActivateDate = (SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WHERE OTA.TrackerID = t.TrackerID)
                LEFT JOIN [User] u1 ON u1.UserID = ota.ModifiedByID
                LEFT JOIN [User] u2 ON u2.UserID = ta.CreatedBy
                LEFT JOIN [User] u3 ON u3.UserID = t.ModifiedByID
                LEFT JOIN  distributoremployee de on a.DistributorID = de.DistributorID
        WHERE
                t.Deleted = 0 
                AND (@AgencyID = 0 OR a.AgencyID = @AgencyID)
		AND
		(
				((@RoleID = 6) AND (a.DistributorID IN (	SELECT	de.DistributorID 
					FROM	distributoremployee de
					WHERE	de.UserID=@UserID)))
				OR (@RoleID <> 6)
		)

                AND
                (
                        (o.OffenderID IS NOT NULL)
                        OR
                        (dp1.PropertyValue = @GatewayIp AND dp2.PropertyValue = @GatewayPort)
                )
                AND (
                  ( @RoleID <> 6 )
	        or
		  ( de.UserID = @UserID)
                )

        ORDER BY DeviceStatus ASC
END

IF (@StatusSort = 1)
BEGIN
        SELECT DISTINCT
                t.TrackerID, 
                t.TrackerNumber +   
                        CASE 
                                WHEN t.IsDemo = 1 then ' (Demo)' else ''
                        END AS 'TrackerNumber',
                a.Agency,
                d.[Name] AS 'DeviceName',
                CASE
                        WHEN dp3.PropertyValue = '' THEN '0'
                        ELSE dp3.PropertyValue
                END AS 'DeviceFirmware',
                CASE 
                        WHEN t.RmaID IS NOT NULL THEN @Rma
                        WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL AND ta.TrackerAssignmentTypeID = 1 THEN @Activated
                        WHEN ta.TrackerAssignmentTypeID = 1 THEN @OffenderAssigned
                        WHEN t.CreatedDate < GETDATE() THEN @AgencyAssigned
                        ELSE @Unassigned
        END AS 'DeviceStatus',
                DATEADD( mi, dbo.fnGetUtcOffset(a.AgencyID),
                        CASE
                                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN ota.ActivateDate
                                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NOT NULL THEN ota.DeactivateDate
                                WHEN ta.AssignmentDate IS NOT NULL THEN ta.AssignmentDate
--                              WHEN ta.TrackerAssignmentTypeID = 1 THEN ta.AssignmentDate
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
--                ISNULL(P.propertyValue,'') AS PhoneNumber,
--                ISNULL(P2.propertyValue,'') AS PhoneNumber1,
--                ISNULL(d.PhoneNumber,'') AS PhoneNumber2
        FROM
                Tracker t
                LEFT JOIN Agency a ON t.AgencyID = a.AgencyID AND a.deleted=0
                LEFT JOIN Gateway.dbo.Devices d ON t.TrackerID = d.DeviceID
                LEFT JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID
                        AND ta.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment TA WHERE TA.TrackerID = t.TrackerID)
                LEFT JOIN Offender o ON o.OffenderID = ta.OffenderID AND o.Deleted = 0 AND ta.TrackerAssignmentTypeID = 1
                LEFT JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
                LEFT JOIN officer ON officer.OfficerID = oo.OfficerID 
--                LEFT JOIN Gateway.dbo.deviceProperties P ON P.deviceid =t.TrackerID  and P.propertyID='8203'
--                LEFT JOIN Gateway.dbo.deviceProperties P2 ON P2.deviceid =t.TrackerID  and P2.propertyID='8206'
                LEFT JOIN Gateway.dbo.DeviceProperties dp1 on dp1.DeviceID = d.DeviceID and  dp1.propertyID='8410'
                LEFT JOIN Gateway.dbo.DeviceProperties dp2 on dp2.DeviceID = d.DeviceID and dp2.propertyID='8411'
                LEFT JOIN Gateway.dbo.DeviceProperties dp3 on dp3.DeviceID = d.DeviceID and dp3.propertyID='8016'       
                LEFT JOIN OffenderTrackerActivation ota ON ota.TrackerID = t.TrackerID 
                        AND ota.ActivateDate = (SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WHERE OTA.TrackerID = t.TrackerID)
                LEFT JOIN [User] u1 ON u1.UserID = ota.ModifiedByID
                LEFT JOIN [User] u2 ON u2.UserID = ta.CreatedBy
                LEFT JOIN [User] u3 ON u3.UserID = t.ModifiedByID
                LEFT JOIN  distributoremployee de on a.DistributorID = de.DistributorID
	WHERE
                t.Deleted = 0 
                AND (@AgencyID = 0 OR a.AgencyID = @AgencyID)
		AND
		(
				((@RoleID = 6) AND (a.DistributorID IN (	SELECT	de.DistributorID 
					FROM	distributoremployee de
					WHERE	de.UserID=@UserID)))
				OR (@RoleID <> 6)
		)

                AND
                (
                        (o.OffenderID IS NOT NULL)
                        OR
                        (dp1.PropertyValue = @GatewayIp AND dp2.PropertyValue = @GatewayPort)
                )
                AND (
                  ( @RoleID <> 6 )
	        or
		  ( de.UserID = @UserID)
                )

        ORDER BY DeviceStatus DESC
END
GO
GRANT VIEW DEFINITION ON [TrackerGetGridInfo] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [TrackerGetGridInfo] TO [db_dml]
GO

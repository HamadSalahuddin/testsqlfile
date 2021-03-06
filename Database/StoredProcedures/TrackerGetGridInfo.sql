USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[TrackerGetGridInfo]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrackerGetGridInfo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   TrackerGetGridInfo.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     
 * Purpose:    Gets tracker and offender data for a UI grid.                
 *
 * Modified By: S.Abbasi - 1/21/2011: Added PartNumber field
 *              R.Cole - 1/21/2011: Added IF EXISTS and GRANT
 *                stmts. Reformatted into a readable state,
 *                since it was a mess.  Removed commented out
 *                code.
 * Modified By: S.Abbasi - 1/24/2011: Added PartNumber field default VALUE 'N.A'
 * ******************************************************** */
CREATE PROCEDURE [dbo].[TrackerGetGridInfo] (
    @AgencyID INT,
    @GatewayPort VARCHAR(10),
    @GatewayIp VARCHAR(20),
    @StatusSort INT = 0,
		@RoleID INT = -1,
    @UserID INT = -1
)
AS

DECLARE @AgencyAssigned INT, 
        @OffenderAssigned INT, 
        @Activated INT,
        @Unassigned INT, 
        @Rma INT
        
SET @AgencyAssigned = 1
SET @OffenderAssigned = 2
SET @Activated = 3
SET @Unassigned = 0
SET @Rma = 4

IF (@StatusSort = 0)
  BEGIN
    SELECT DISTINCT t.TrackerID, 
           ISNULL(t.PartNumber,'N.A') AS PartNumber,
           t.TrackerNumber + CASE WHEN t.IsDemo = 1 THEN ' (Demo)' ELSE '' END AS 'TrackerNumber', 
           a.Agency,
           d.[Name] AS 'DeviceName',
           CASE WHEN dp3.PropertyValue = '' THEN '0'
                WHEN dp3.PropertyValue IS NULL THEN '0'
                ELSE dp3.PropertyValue
           END AS 'DeviceFirmware',
           CASE WHEN t.RmaID IS NOT NULL THEN @Rma
                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL AND ta.TrackerAssignmentTypeID = 1 THEN @Activated
                WHEN ta.TrackerAssignmentTypeID = 1 THEN @OffenderAssigned
                WHEN t.CreatedDate < GETDATE() THEN @AgencyAssigned
                ELSE @Unassigned
	         END AS 'DeviceStatus',
           DATEADD( mi, dbo.fnGetUtcOffset(a.AgencyID), CASE WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN ota.ActivateDate
                                                             WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NOT NULL THEN ota.DeactivateDate
                                                             WHEN ta.AssignmentDate IS NOT NULL THEN ta.AssignmentDate
                                                             WHEN t.CreatedDate < GETDATE() THEN t.ModifiedDate
                                                        END
           ) AS 'StatusModifiedDate',
           CASE WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN u1.UserName
                WHEN ta.TrackerAssignmentTypeID = 1 THEN u2.UserName
                WHEN t.CreatedDate < GETDATE() THEN u3.UserName
           END AS 'StatusModifiedBy',              
           CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(o.FirstName, '')+' '+ISNULL(o.MiddleName, '')+' '+ISNULL(o.LastName, '') ELSE '' END AS 'OffenderName',
           CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(officer.FirstName, '')+' '+ISNULL(officer.MiddleName, '')+' '+ISNULL(officer.LastName, '') ELSE '' END AS 'officerName'
    FROM Tracker t
      LEFT OUTER JOIN Agency a ON t.AgencyID = a.AgencyID AND a.deleted = 0
      LEFT OUTER JOIN Gateway.dbo.Devices d ON t.TrackerID = d.DeviceID
      LEFT OUTER JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID
                  AND ta.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment TA WHERE TA.TrackerID = t.TrackerID)
      LEFT OUTER JOIN Offender o ON o.OffenderID = ta.OffenderID AND o.Deleted = 0 AND ta.TrackerAssignmentTypeID = 1
      LEFT OUTER JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
      LEFT OUTER JOIN officer ON officer.OfficerID = oo.OfficerID 
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp1 on dp1.DeviceID = d.DeviceID and dp1.propertyID='8410'
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp2 on dp2.DeviceID = d.DeviceID and dp2.propertyID='8411'
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp3 on dp3.DeviceID = d.DeviceID and dp3.propertyID='8016'       
		  LEFT OUTER JOIN OffenderTrackerActivation ota ON ota.TrackerID = t.TrackerID 
                  AND ota.ActivateDate = (SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WHERE OTA.TrackerID = t.TrackerID)
      LEFT OUTER JOIN [User] u1 ON u1.UserID = ota.ModifiedByID
      LEFT OUTER JOIN [User] u2 ON u2.UserID = ta.CreatedBy
      LEFT OUTER JOIN [User] u3 ON u3.UserID = t.ModifiedByID
      LEFT OUTER JOIN  distributoremployee de on a.DistributorID = de.DistributorID
    WHERE t.Deleted = 0 
      AND ((@AgencyID = 0 ) OR (a.AgencyID = @AgencyID))
		  AND (((@RoleID = 6) AND (a.DistributorID IN (	SELECT	de.DistributorID 
					                                          FROM	distributoremployee de
					                                          WHERE	de.UserID=@UserID))) OR (@RoleID <> 6))
      AND ((o.OffenderID IS NOT NULL) OR ((dp1.PropertyValue = @GatewayIp) AND (dp2.PropertyValue = @GatewayPort)))
      AND (( @RoleID <> 6 ) OR ( de.UserID = @UserID))
    ORDER BY a.Agency, 'TrackerNumber'
END

IF (@StatusSort =-1)
  BEGIN
    SELECT DISTINCT t.TrackerID, 
           ISNULL(t.PartNumber,'N.A') AS PartNumber,
           t.TrackerNumber + CASE WHEN t.IsDemo = 1 THEN ' (Demo)' ELSE '' END AS 'TrackerNumber',
           a.Agency,
           d.[Name] AS 'DeviceName',
           CASE WHEN dp3.PropertyValue = '' THEN '0' ELSE dp3.PropertyValue END AS 'DeviceFirmware',
           CASE WHEN t.RmaID IS NOT NULL THEN @Rma
                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL AND ta.TrackerAssignmentTypeID = 1 THEN @Activated
                WHEN ta.TrackerAssignmentTypeID = 1 THEN @OffenderAssigned
                WHEN t.CreatedDate < GETDATE() THEN @AgencyAssigned
                ELSE @Unassigned
           END AS 'DeviceStatus',
           DATEADD( mi, dbo.fnGetUtcOffset(a.AgencyID), CASE WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN ota.ActivateDate
                                                             WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NOT NULL THEN ota.DeactivateDate
                                                             WHEN ta.AssignmentDate IS NOT NULL THEN ta.AssignmentDate
                                                             WHEN t.CreatedDate < GETDATE() THEN t.ModifiedDate
                                                        END 
           ) AS 'StatusModifiedDate',
           CASE WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN u1.UserName
                WHEN ta.TrackerAssignmentTypeID = 1 THEN u2.UserName
                WHEN t.CreatedDate < GETDATE() THEN u3.UserName
           END AS 'StatusModifiedBy',              
           CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(o.FirstName, '')+' '+ISNULL(o.MiddleName, '')+' '+ISNULL(o.LastName, '') ELSE '' END AS 'OffenderName',
           CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(officer.FirstName, '')+' '+ISNULL(officer.MiddleName, '')+' '+ISNULL(officer.LastName, '') ELSE '' END AS 'officerName'
    FROM Tracker t
      LEFT OUTER JOIN Agency a ON t.AgencyID = a.AgencyID AND a.deleted=0
      LEFT OUTER JOIN Gateway.dbo.Devices d ON t.TrackerID = d.DeviceID
      LEFT OUTER JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID
                  AND ta.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment TA WHERE TA.TrackerID = t.TrackerID)
      LEFT OUTER JOIN Offender o ON o.OffenderID = ta.OffenderID AND o.Deleted = 0 AND ta.TrackerAssignmentTypeID = 1
      LEFT OUTER JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
      LEFT OUTER JOIN officer ON officer.OfficerID = oo.OfficerID
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp1 on dp1.DeviceID = d.DeviceID and  dp1.propertyID='8410'
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp2 on dp2.DeviceID = d.DeviceID and dp2.propertyID='8411'
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp3 on dp3.DeviceID = d.DeviceID and dp3.propertyID='8016'       
      LEFT OUTER JOIN OffenderTrackerActivation ota ON ota.TrackerID = t.TrackerID 
                  AND ota.ActivateDate = (SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WHERE OTA.TrackerID = t.TrackerID)
      LEFT OUTER JOIN [User] u1 ON u1.UserID = ota.ModifiedByID
      LEFT OUTER JOIN [User] u2 ON u2.UserID = ta.CreatedBy
      LEFT OUTER JOIN [User] u3 ON u3.UserID = t.ModifiedByID
      LEFT OUTER JOIN  distributoremployee de on a.DistributorID = de.DistributorID
    WHERE t.Deleted = 0 
      AND (@AgencyID = 0 OR a.AgencyID = @AgencyID)
		  AND (((@RoleID = 6) AND (a.DistributorID IN (	SELECT	de.DistributorID 
					                                          FROM	distributoremployee de
					                                          WHERE	de.UserID=@UserID))) OR (@RoleID <> 6))
      AND ((o.OffenderID IS NOT NULL) OR (dp1.PropertyValue = @GatewayIp AND dp2.PropertyValue = @GatewayPort))
      AND (( @RoleID <> 6 ) OR (de.UserID = @UserID))
    ORDER BY DeviceStatus ASC
END

IF (@StatusSort = 1)
  BEGIN
    SELECT DISTINCT t.TrackerID, 
           t.TrackerNumber + CASE WHEN t.IsDemo = 1 THEN ' (Demo)' ELSE '' END AS 'TrackerNumber',
           a.Agency,
           d.[Name] AS 'DeviceName',
           CASE WHEN dp3.PropertyValue = '' THEN '0' ELSE dp3.PropertyValue END AS 'DeviceFirmware',
           CASE WHEN t.RmaID IS NOT NULL THEN @Rma
                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL AND ta.TrackerAssignmentTypeID = 1 THEN @Activated
                WHEN ta.TrackerAssignmentTypeID = 1 THEN @OffenderAssigned
                WHEN t.CreatedDate < GETDATE() THEN @AgencyAssigned
                ELSE @Unassigned
           END AS 'DeviceStatus',
           DATEADD( mi, dbo.fnGetUtcOffset(a.AgencyID),
           CASE WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN ota.ActivateDate
                WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NOT NULL THEN ota.DeactivateDate
                WHEN ta.AssignmentDate IS NOT NULL THEN ta.AssignmentDate
                WHEN t.CreatedDate < GETDATE() THEN t.ModifiedDate
           END) AS 'StatusModifiedDate',
           CASE WHEN ota.ActivateDate < GETDATE() AND ota.DeActivateDate IS NULL THEN u1.UserName
                WHEN ta.TrackerAssignmentTypeID = 1 THEN u2.UserName
                WHEN t.CreatedDate < GETDATE() THEN u3.UserName
           END AS 'StatusModifiedBy',              
           CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(o.FirstName, '')+' '+ISNULL(o.MiddleName, '')+' '+ISNULL(o.LastName, '') ELSE '' END AS 'OffenderName',
           CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN ISNULL(officer.FirstName, '')+' '+ISNULL(officer.MiddleName, '')+' '+ISNULL(officer.LastName, '') ELSE '' END AS 'officerName'
    FROM Tracker t
      LEFT OUTER JOIN Agency a ON t.AgencyID = a.AgencyID AND a.deleted=0
      LEFT OUTER JOIN Gateway.dbo.Devices d ON t.TrackerID = d.DeviceID
      LEFT OUTER JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID
            AND ta.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment TA WHERE TA.TrackerID = t.TrackerID)
      LEFT OUTER JOIN Offender o ON o.OffenderID = ta.OffenderID AND o.Deleted = 0 AND ta.TrackerAssignmentTypeID = 1
      LEFT OUTER JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
      LEFT OUTER JOIN officer ON officer.OfficerID = oo.OfficerID 
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp1 on dp1.DeviceID = d.DeviceID and  dp1.propertyID='8410'
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp2 on dp2.DeviceID = d.DeviceID and dp2.propertyID='8411'
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp3 on dp3.DeviceID = d.DeviceID and dp3.propertyID='8016'       
      LEFT OUTER JOIN OffenderTrackerActivation ota ON ota.TrackerID = t.TrackerID 
                  AND ota.ActivateDate = (SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WHERE OTA.TrackerID = t.TrackerID)
      LEFT OUTER JOIN [User] u1 ON u1.UserID = ota.ModifiedByID
      LEFT OUTER JOIN [User] u2 ON u2.UserID = ta.CreatedBy
      LEFT OUTER JOIN [User] u3 ON u3.UserID = t.ModifiedByID
      LEFT OUTER JOIN  distributoremployee de on a.DistributorID = de.DistributorID
    WHERE t.Deleted = 0 
      AND (@AgencyID = 0 OR a.AgencyID = @AgencyID)
		  AND (((@RoleID = 6) AND (a.DistributorID IN (	SELECT	de.DistributorID 
					                                          FROM	distributoremployee de
					                                          WHERE	de.UserID=@UserID))) OR (@RoleID <> 6))
      AND ((o.OffenderID IS NOT NULL) OR (dp1.PropertyValue = @GatewayIp AND dp2.PropertyValue = @GatewayPort))
      AND (( @RoleID <> 6 ) OR (de.UserID = @UserID))
    ORDER BY DeviceStatus DESC
END
GO

GRANT EXECUTE ON [dbo].[TrackerGetGridInfo] TO db_dml;
GO
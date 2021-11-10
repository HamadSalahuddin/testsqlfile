USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spReportOTDAgencyOffenderAssignmentDetail]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spReportOTDAgencyOffenderAssignmentDetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spReportOTDAgencyOffenderAssignmentDetail.sql
 * Created On: 4/23/2008         
 * Created By: F.Meads
 * Task #:     N/A
 * Purpose:    Return data to AgencyOffenderAssignment Report               
 *
 * Modified By: R.Cole - 9/24/2013 - Fixed time conversion bugs,
 *              revised to meet coding standard. Added new column
 *              DeactivatedBy to the report.
 * ******************************************************** */
CREATE PROCEDURE [spReportOTDAgencyOffenderAssignmentDetail]
AS
BEGIN
  SET NOCOUNT ON;
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

  DECLARE @UTCOffset INT

  SET @UTCOffset = dbo.fnGetMSTOffset(8)

  SELECT dp.PropertyValue AS 'Gateway Serial Number',
         Agency.Agency,
         (CASE WHEN Tracker.CreatedDate IS NULL THEN 'N/A' ELSE CONVERT(CHAR(25), DATEADD(MI, @UTCOffset, Tracker.CreatedDate), 101) END) AS 'AgencyAssignmentDate',
         (CASE WHEN Tracker.Deleted = 1 THEN CONVERT(CHAR(25), DATEADD(MI, @UTCOffset, Tracker.ModifiedDate), 101) ELSE '' END ) AS 'Agency Un-AssignmentDate',
         (CASE WHEN Officer.OfficerID IS NULL THEN 'NotAssigned' ELSE Officer.FirstNAme + ' ' + Officer.LastName END) AS 'Officer Name',
         (CASE WHEN Officer.Dayphone IS NULL THEN '' WHEN Officer.DayPhone = ' ' THEN Officer.Mobilephone WHEN Officer.Dayphone != '' THEN Officer.Dayphone ELSE '' END)AS 'Officer Phone',
			   CONVERT(CHAR(25), DATEADD(MI, @UTCOffset, ta.AssignmentDate), 101) AS 'AssignmentDate',
         (CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN 'Assigned' ELSE 'Unassigned' END) AS 'AssignmentStatus',
         (CASE WHEN Offender.OffenderID IS NULL THEN 'Not Assigned' ELSE Offender.FirstName + ' ' + Offender.LastNAme END) AS 'Assigned Offender',
         (CASE WHEN ota.ActivateDate IS NULL THEN 'N/A' ELSE CONVERT(CHAR(25), DATEADD(MI, @UTCOffset, ota.ActivateDate), 101) END) AS 'Activation Date',
         (CASE WHEN ota.ActivateDate IS NULL THEN 'N/A' WHEN ota.ActivateDate IS NOT NULL AND ota.DeactivateDate IS NULL THEN 'Active' ELSE CONVERT(CHAR(25), DATEADD(MI, @UTCOffset, ota.DeactivateDate), 101) END) AS 'Deactivation Date',         
         (CASE WHEN ota.DeactivateDate IS NOT NULL THEN COALESCE(Officer1.FirstName + ' ' + Officer1.LastName, de.FirstName + ' ' + de.LastName, Operator.FirstName + ' ' + Operator.LastName) END) AS 'DeactivatedBy',         
         (CASE WHEN Devices.LastEventTime !=0 THEN CONVERT(CHAR(25), DATEADD(MI, @UTCOffset, Trackerpal.dbo.ConvertLongToDate(Devices.LastEventTime)), 101) ELSE 'N/A' END) AS 'LastEvent'
  FROM Gateway.dbo.Devices Devices WITH (NOLOCK)
    LEFT OUTER JOIN (SELECT TrackerID, Max(TrackerActivationID) AS ActivationID FROM OffenderTrackerActivation WITH (NOLOCK) GROUP BY TrackerID) AS ota1 ON ota1.TrackerID = Devices.DeviceID
    LEFT OUTER JOIN (SELECT TrackerID, Max(TrackerAssignmentID) AS AssignmentID FROM TrackerAssignment WITH (NOLOCK)GROUP BY TrackerID) AS ta1 ON ta1.TrackerID = Devices.DeviceID
    LEFT OUTER JOIN (SELECT TrackerID, Max(TrackerUniqueID) AS UniqueID FROM Tracker WITH (NOLOCK) GROUP BY TrackerID) AS t ON t.TrackerID = Devices.DeviceID
    LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON Devices.DeviceID = dp.DeviceID AND dp.PropertyID = '8012'
    LEFT OUTER JOIN OffenderTrackerActivation ota ON ota.TrackerActivationID = ota1.ActivationID
    LEFT OUTER JOIN TrackerAssignment ta ON ta.TrackerAssignmentID = ta1.AssignmentID
    LEFT OUTER JOIN Tracker ON t.UniqueID = Tracker.TrackerUniqueID
    INNER JOIN Agency ON Tracker.AgencyID = Agency.AgencyID
    LEFT OUTER JOIN Offender ON Offender.OffenderID = ta.OffenderID
    LEFT OUTER JOIN Officer ON Officer.OfficerID = ta.SupervisionOfficerID
    LEFT OUTER JOIN Operator ON Operator.UserID = ota.ModifiedByID
    LEFT OUTER JOIN DistributorEmployee de ON de.UserID = ota.ModifiedByID
    LEFT OUTER JOIN Officer Officer1 ON Officer1.UserID = ota.ModifiedByID
  ORDER BY Agency.Agency
END
GO

GRANT EXECUTE ON [spReportOTDAgencyOffenderAssignmentDetail] TO [db_dml]
GO

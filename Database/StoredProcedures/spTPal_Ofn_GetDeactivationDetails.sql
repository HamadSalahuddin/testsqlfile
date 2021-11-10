USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetDeactivationDetails]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetDeactivationDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetDeactivationDetails.sql
 * Created On: 03/21/2012         
 * Created By: R.Cole
 * Task #:     3045
 * Purpose:    Get offender details for the TrackerPal_V2 
 *             deactivation screen.  
 *
 * Modified By: R.Cole - 4/16/2012: Per #3270, fixed an 
 *            issue where multiple rows could be returned
 *            resulting in no serial number being displayed.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetDeactivationDetails] (
  @OffenderID INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Correct Name Concatentation code, handles NULLS and EmptyString:  BAM!
-- Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS Khan,

-- // Main Query // --
SELECT Offender.FirstName AS OffenderFirstName,    
       Offender.MiddleName AS OffenderMiddleName,
       Offender.LastName AS OffenderLastName,
       Agency.Agency,
       Agency.AgencyID,
       Officer.FirstName AS OfficerFirstName,
       Officer.MiddleName AS OfficerMiddleName,
       Officer.LastName AS OfficerLastName,
       LEFT(Tracker.TrackerName,8) AS SerialNumber,
       Tracker.TrackerID AS TrackerID
FROM OffenderTrackerActivation ota
  INNER JOIN Offender ON ota.OffenderID = Offender.OffenderID
  INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
  INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
  INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
  LEFT JOIN TrackerAssignment ON Offender.OffenderID = TrackerAssignment.OffenderID
        AND TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment ta WHERE ta.OffenderID = Offender.OffenderID)
  INNER JOIN Tracker ON TrackerAssignment.TrackerID = Tracker.TrackerID
WHERE ota.OffenderID = @OffenderID
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker T WHERE t.TrackerID = Tracker.TrackerID)
  AND TrackerAssignment.TrackerAssignmentTypeID = 1     -- Ensure device is still assigned to offender
  AND ota.DeactivateDate IS NULL                        -- Ensure device hasn't been deactivated already
GROUP BY Offender.FirstName,
         Offender.MiddleName,
         Offender.LastName,
         Officer.FirstName,
         Officer.MiddleName,
         Officer.LastName,
         Agency.Agency,
         Agency.AgencyID,
         Tracker.TrackerID,
         Tracker.TrackerName
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetDeactivationDetails] TO db_dml;
GO
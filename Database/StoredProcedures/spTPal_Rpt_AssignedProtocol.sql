USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AssignedProtocol]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AssignedProtocol]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AssignedProtocol.sql
 * Created On: 02/17/2012         
 * Created By: R.Cole 
 * Task #:     #3090
 * Purpose:    Given an AgencyID, return a list of active
 *             offenders and their assigned protocol.               
 *
 * Modified By:  R.Cole - 3/5/2012: Added code to handle Distributors,
 *                and Application Admins.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AssignedProtocol] (
  @AgencyID INT,
  @DistributorID INT = NULL 
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Main Query // --
IF ((@DistributorID IS NOT NULL) AND (@AgencyID = -1))
  BEGIN
    -- // Get Resultset for All Agencies belonging to Distributor // --
    SELECT DISTINCT Offender.OffenderID,
           Agency.Agency,
           Offender.FirstName + ' ' + ISNULL(Offender.MiddleName,'') + ' ' + Offender.LastName AS [Offender],
           AlarmProtocolSet.AlarmProtocolSetName AS [Protocol]
    FROM AlarmProtocolSet
      INNER JOIN Offender_AlarmProtocolSet ON AlarmProtocolSet.AlarmProtocolSetID = Offender_AlarmProtocolSet.AlarmProtocolSetID
      INNER JOIN Offender ON Offender_AlarmProtocolSet.OffenderID = Offender.OffenderID
      INNER JOIN OffenderTrackerActivation ON Offender.OffenderID = OffenderTrackerActivation.OffenderID
      INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
    WHERE Agency.DistributorID = @DistributorID
      AND OffenderTrackerActivation.ActivateDate = (SELECT MAX(ActivateDate)
                                                    FROM OffenderTrackerActivation ota
                                                    WHERE ota.OffenderID = Offender.OffenderID
                                                      AND ota.DeactivateDate IS NULL)
      AND Agency.Deleted = 0
      AND Offender.Deleted = 0
    ORDER BY Agency.Agency ASC,
             Offender.FirstName + ' ' + ISNULL(Offender.MiddleName,'') + ' ' + Offender.LastName ASC
  END
ELSE
  BEGIN
    -- // Get Resultset for Single Agency // --
    SELECT DISTINCT Offender.OffenderID,
           Agency.Agency,
           Offender.FirstName + ' ' + ISNULL(Offender.MiddleName,'') + ' ' + Offender.LastName AS [Offender],
           AlarmProtocolSet.AlarmProtocolSetName AS [Protocol]
    FROM AlarmProtocolSet
      INNER JOIN Offender_AlarmProtocolSet ON AlarmProtocolSet.AlarmProtocolSetID = Offender_AlarmProtocolSet.AlarmProtocolSetID
      INNER JOIN Offender ON Offender_AlarmProtocolSet.OffenderID = Offender.OffenderID
      INNER JOIN OffenderTrackerActivation ON Offender.OffenderID = OffenderTrackerActivation.OffenderID
      INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
    WHERE Agency.AgencyID = @AgencyID
      AND OffenderTrackerActivation.ActivateDate = (SELECT MAX(ActivateDate) 
                                                    FROM OffenderTrackerActivation ota
                                                    WHERE ota.OffenderID = Offender.OffenderID
                                                      AND ota.DeactivateDate IS NULL)
      AND Offender.Deleted = 0
      AND Offender_AlarmProtocolSet.Deleted = 0
    ORDER BY Agency.Agency ASC,
             Offender.FirstName + ' ' + ISNULL(Offender.MiddleName,'') + ' ' + Offender.LastName ASC
  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AssignedProtocol] TO db_dml;
GO
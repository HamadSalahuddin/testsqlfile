USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_ActiveProtocolsByAgency]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_ActiveProtocolsByAgency]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_ActiveProtocolsByAgency.sql
 * Created On: 02/17/2012         
 * Created By: R.Cole 
 * Task #:     #3145
 * Purpose:    Return the active protocols by agency to a
 *             report.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_ActiveProtocolsByAgency] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Main Query // --
SELECT Agency.AgencyID,
       Agency.Agency,
       AlarmProtocolSet.AlarmProtocolSetName AS [Protocol],
       COUNT(Offender_AlarmProtocolSet.OffenderID) AS [Offenders]
FROM AlarmProtocolSet
  INNER JOIN Agency ON AlarmProtocolSet.AgencyID = Agency.AgencyID
  INNER JOIN Offender_AlarmProtocolSet ON AlarmProtocolSet.AlarmProtocolSetID = Offender_AlarmProtocolSet.AlarmProtocolSetID
  INNER JOIN Offender ON Offender_AlarmProtocolSet.OffenderID = Offender.OffenderID
  INNER JOIN OffenderTrackerActivation ON Offender.OffenderID = OffenderTrackerActivation.OffenderID
WHERE Offender_AlarmProtocolSet.Deleted = 0
  AND Offender.Deleted = 0
  AND Agency.Deleted = 0
  AND (OffenderTrackerActivation.ActivateDate IS NOT NULL AND OffenderTrackerActivation.DeactivateDate IS NULL)
  AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)
GROUP BY Agency.AgencyID,
         Agency.Agency,
         AlarmProtocolSet.AlarmProtocolSetName
ORDER BY Agency.Agency ASC

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_ActiveProtocolsByAgency] TO db_dml;
GO
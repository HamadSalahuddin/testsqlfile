USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_OffenderProtocolException]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_OffenderProtocolException]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_OffenderProtocolException.sql
 * Created On: 03/28/2011         
 * Created By: S.Fieber
 * Task #:     #1982
 * Purpose:    Returns those offenders who have an intervention
 *             active protocol when they should be on Standard
 *             active or passive.  Results used in a daily
 *             exception report.            
 *
 * Modified By: R.Cole - 03/28/2011: Revised to meet standard
 *              and converted to stored procedure.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_OffenderProtocolException] 

AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT DISTINCT Agency.Agency,
       Offender.LastName + ' ' + Offender.FirstName AS Offender,
       OffenderServiceBilling.StartDate
FROM OffenderServiceBilling 
  INNER JOIN Offender on Offender.OffenderID = OffenderServiceBilling.OffenderID
  INNER JOIN Agency on Agency.AgencyID = Offender.AgencyID
  INNER JOIN Offender_AlarmProtocolSet ON Offender_AlarmProtocolSet.OffenderID = Offender.OffenderID
WHERE (OffenderServiceBilling.EndDate IS NULL AND OffenderServiceBilling.ServiceID IN (2, 3, 6, 8)) 
  AND (AlarmProtocolSetID NOT IN (2957, 2958, 3757, 3756) AND Offender_AlarmProtocolSet.ModifiedDate IS NULL)  -- Show only currently broken offenders
ORDER BY OffenderServiceBilling.StartDate DESC
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_OffenderProtocolException] TO db_dml;
GO
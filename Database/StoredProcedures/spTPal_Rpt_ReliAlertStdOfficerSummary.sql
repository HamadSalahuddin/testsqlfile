USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_ReliAlertStdOfficerSummary]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_ReliAlertStdOfficerSummary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_ReliAlertStdOfficerSummary.sql
 * Created On: 03/22/2011
 * Created By: R.Cole
 * Task #:     2026/2114
 * Purpose:    Return data for the daily ReliAlert Standard
 *             officer summary report.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [spTPal_Rpt_ReliAlertStdOfficerSummary] (
  @Officerid int,
  @Agencyid int
)
AS

-- // Build temp table // --
SELECT * 
INTO #tmplast24events
FROM rprtEventsBucket1 Bucket1
WHERE dbo.fnUtcToLocal(@AgencyID, Bucket1.EventDateTime) BETWEEN DATEADD(hh,-24,CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))) AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))
  AND Bucket1.AlarmType > 1
  AND Bucket1.OfficerID = @OfficerID
  AND Bucket1.AgencyID = @AgencyID
  
-- // Build final results // -- 
Select Offender.LastName + ', ' + Offender.FirstName AS OffenderName,
       SUM(CASE WHEN tmp.EventID IS NULL THEN 0 ELSE 1 END) AS AlarmTotal
From Offender
  LEFT JOIN #tmplast24events tmp ON tmp.OffenderID = Offender.OffenderID
  INNER JOIN OptionalBillingServiceOptionOffender obsoo ON obsoo.OffenderID = Offender.OffenderID
  INNER JOIN BillingServiceOption bso ON bso.id = obsoo.BillingServiceOptionID
  INNER JOIN ClassicBillingService cbs ON cbs.BillingServiceID = bso.BillingServiceID
WHERE Offender.Deleted = 0 
  AND tmp.OfficerID = @OfficerID 
  AND Offender.AgencyID = @AgencyID 
  AND cbs.ServiceID = 8
GROUP BY Offender.LastName + ', ' + Offender.firstname
Order BY Offender.LastName + ', ' + Offender.firstname

-- // Clean up // --
drop table #tmplast24events
GO

GRANT EXECUTE ON [spTPal_Rpt_ReliAlertStdOfficerSummary] TO [db_dml]
GO

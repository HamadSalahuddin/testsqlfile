USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_ReliAlertStdAgencySummary]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_ReliAlertStdAgencySummary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_ReliAlertStdAgencySummary.sql
 * Created On: 3/22/2011
 * Created By: R.Cole
 * Task #:     2026/2114
 * Purpose:    Return summary data for the daily Agency level
 *             ReliAlert Standard report.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [spTPal_Rpt_ReliAlertStdAgencySummary] (
  @AgencyID INT
)
AS

-- // Build temp table // --
SELECT Bucket1.*             
INTO #tmplast24events
FROM rprtEventsBucket1 Bucket1
  INNER JOIN OptionalBillingServiceOptionOffender obsoo ON obsoo.OffenderID = Bucket1.OffenderID
  INNER JOIN BillingServiceOption bso ON bso.ID = obsoo.BillingServiceOptionID
  INNER JOIN ClassicBillingService cbs ON cbs.BillingServiceID = bso.BillingServiceID
WHERE dbo.fnUtcToLocal(@AgencyID,Bucket1.EventDateTime) BETWEEN DATEADD(hh,-24,CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))) AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))
  AND Bucket1.AlarmType > 1
  AND Bucket1.AgencyID = @AgencyID
  AND cbs.ServiceID = 8
 
-- // Build final results // -- 
SELECT Officer.LastName + ', ' + Officer.FirstName AS OfficerName,
       SUM(CASE WHEN tmp.EventID IS NULL THEN 0 ELSE 1 END) AS AlarmTotal
FROM Offender 
  LEFT JOIN #tmplast24events tmp ON tmp.OffenderID = Offender.OffenderID
  INNER JOIN OptionalBillingServiceOptionOffender obsoo ON obsoo.OffenderID = Offender.OffenderID
  INNER JOIN BillingServiceOption bso ON bso.ID = obsoo.BillingServiceOptionID
  INNER JOIN ClassicBillingservice cbs ON cbs.BillingServiceID = bso.BillingServiceID
  INNER JOIN Offender_Officer oo ON oo.OffenderID = Offender.OffenderID
  INNER JOIN Officer ON Officer.OfficerID = oo.OfficerID
WHERE Offender.Deleted = 0 
  AND Offender.AgencyID = @AgencyID 
  AND cbs.ServiceID = 8
GROUP BY Officer.LastName + ', ' + Officer.FirstName
ORDER BY Officer.LastName + ', ' + Officer.FirstName

-- // Clean up // --
DROP TABLE #tmplast24events
GO

GRANT EXECUTE ON [spTPal_Rpt_ReliAlertStdAgencySummary] TO [db_dml]
GO

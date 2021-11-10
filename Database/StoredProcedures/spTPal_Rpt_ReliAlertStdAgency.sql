USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_ReliAlertStdAgency]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_ReliAlertStdAgency]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_ReliAlertStdAgency.sql
 * Created On: 3/22/2011         
 * Created By: R.Cole
 * Task #:     2114/2026
 * Purpose:    Return data for the daily Agency level ReliAlert
 *             Standard report.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [spTPal_Rpt_ReliAlertStdAgency] (
  @AgencyID INT
)
AS
SELECT Officer.LastName + ', ' + Officer.FirstName As 'Officer',
       Offender.LastName + ', ' + Offender.FirstName As 'Offender',
       Bucket1.EventName,
       dbo.fnUtcToLocal(@AgencyID, Bucket1.EventDateTime) AS 'Time',
       Bucket1.Address AS 'Location',
       Bucket1.GeoRule AS 'Rule',
       Agency.Agency as 'Agency'
From dbo.rprtEventsBucket1 Bucket1
  INNER JOIN Officer ON Officer.OfficerID = Bucket1.officerID
  INNER JOIN Offender ON Offender.OffenderID = Bucket1.OffenderID
  INNER JOIN OptionalBillingServiceOptionOffender obsoo ON obsoo.OffenderID = Bucket1.OffenderID
  INNER JOIN BillingServiceOption bso ON bso.ID = obsoo.BillingServiceOptionID
  INNER JOIN ClassicBillingService cbs ON cbs.BillingServiceID = bso.BillingServiceID
  INNER JOIN Agency ON Agency.AgencyID = Bucket1.AgencyID
  INNER JOIN Timezone ON Timezone.TimezoneID = Agency.TimezoneID
WHERE dbo.fnUtcToLocal(@AgencyID, Bucket1.EventDateTime) BETWEEN DATEADD(hh,-24,CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))) AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))
  AND Bucket1.AgencyID = @AgencyID 
  AND Bucket1.AlarmType > 1 
  AND cbs.ServiceID = 8
ORDER BY Officer.LastName + ', ' + Officer.FirstName,
         Offender.LastName + ', ' + Offender.FirstName,
         Bucket1.EventDateTime
GO

GRANT EXECUTE ON [spTPal_Rpt_ReliAlertStdAgency] TO [db_dml]
GO

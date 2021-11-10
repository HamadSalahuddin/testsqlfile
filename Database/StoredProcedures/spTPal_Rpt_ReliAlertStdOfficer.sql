USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_ReliAlertStdOfficer]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_ReliAlertStdOfficer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_ReliAlertStdOfficer.sql
 * Created On: 03/22/2011
 * Created By: R.Cole
 * Task #:     2026/2114
 * Purpose:    Return data for the daily ReliAlert Standard
 *             officer report.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [spTPal_Rpt_ReliAlertStdOfficer] (
  @OfficerID INT,
  @AgencyID INT
)
AS
SELECT Officer.LastName + ', ' + Officer.FirstName As 'Officer',
       Offender.Lastname + ', ' + Offender.Firstname AS OffenderName,
       Bucket1.EventName,
       dbo.fnUtcToLocal(@AgencyID, Bucket1.EventDateTime) AS 'Time',
       Bucket1.Address AS 'Location',
       Bucket1.GeoRule AS 'Rule',
       Agency.Agency as 'Agency'
From dbo.rprtEventsBucket1 Bucket1
  INNER JOIN Offender ON Offender.OffenderID = Bucket1.OffenderID
  INNER JOIN Officer ON Officer.OfficerID = Bucket1.OfficerID
  INNER JOIN Agency ON Agency.AgencyID = Bucket1.AgencyID
  INNER JOIN Timezone ON Timezone.TimezoneID = Agency.TimezoneID
  INNER JOIN OptionalBillingServiceOptionOffender obsoo ON obsoo.OffenderID = Offender.OffenderID
  INNER JOIN BillingServiceOption bso ON bso.ID = obsoo.BillingServiceOptionID
  INNER JOIN ClassicBillingservice cbs ON cbs.BillingserviceID = bso.BillingserviceID
WHERE dbo.fnUtcToLocal(@Agencyid,Bucket1.EventDateTime) BETWEEN DATEADD(hh,-24,CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))) AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT,dbo.fnUtcToLocal(@AgencyID,GETDATE()))))
  AND Bucket1.OfficerID = @OfficerID
  AND Bucket1.AlarmType > 1 
  AND cbs.ServiceID = 8
ORDER BY OffenderName,
         Bucket1.EventDateTime
GO

GRANT EXECUTE ON [spTPal_Rpt_ReliAlertStdOfficer] TO [db_dml]
GO

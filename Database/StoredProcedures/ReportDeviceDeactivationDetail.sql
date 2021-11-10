USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[ReportDeviceDeactivationDetail]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReportDeviceDeactivationDetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   ReportDeviceDeactivationDetail.sql
 * Created On: Unknown
 * Created By: Aculis, Inc  
 * Task #:     <Redmine #>      
 * Purpose:    TrackerPal Report               
 *
 * Modified By: R.Cole - 09/22/2010 Fixed a bug that reported
 *                       the incorrect deactivation time/date.
 *                       Brought up to standard.
 * ******************************************************** */
CREATE PROCEDURE [ReportDeviceDeactivationDetail] (
    @Date DATETIME,
    @TimezoneOffset INT
)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @DayBegin DATETIME, 
        @DayEnd DATETIME, 
        @DaylightOffset INT

SET @TimezoneOffset = -@TimezoneOffset
SET @DayBegin = DATEADD(MINUTE, @TimezoneOffset, @Date)
SET @DayEnd = DATEADD(DAY, 1, @DayBegin)

SELECT ota.TrackerID,
       Devices.[Name],
       Agency.SFDCAccount AS 'SFDCACCT#',
       REPLACE(Agency.Agency, ',', ';' ) AS 'Agency',
       DATEADD(MINUTE, @TimezoneOffset, ota.DeactivateDate) AS 'DeactivateDate',
       CONVERT(VARCHAR,ota.TrackerDeactivationReasonID)  + ' - ' + ota.ReasonText AS 'Deactivate Reason',
       Offender.FirstName + ' ' + Offender.LastName AS 'Offender',
       usr.UserName
FROM OffenderTrackerActivation ota
  LEFT OUTER JOIN Offender ON ota.OffenderID = Offender.OffenderID
  LEFT OUTER JOIN Agency ON Agency.AgencyID = Offender.AgencyID
  LEFT OUTER JOIN [User] usr ON usr.UserID = ota.ModifiedByID
  LEFT OUTER JOIN Gateway.dbo.Devices Devices ON Devices.DeviceID = ota.TrackerID
WHERE ota.DeActivateDate >= @DayBegin 
  AND ota.DeActivateDate < @DayEnd
ORDER BY Agency.Agency, 
         ota.TrackerID
GO

GRANT EXECUTE ON [ReportDeviceDeactivationDetail] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReportDeviceDeactivationDetail] TO [db_object_def_viewers]
GO

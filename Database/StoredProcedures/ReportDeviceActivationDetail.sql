USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[ReportDeviceActivationDetail]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReportDeviceActivationDetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   ReportDeviceActivationDetail.sql
 * Created On: Unknown
 * Created By: Aculis, Inc  
 * Task #:     <Redmine #>      
 * Purpose:    TrackerPal Report               
 *
 * Modified By: R.Cole - 09/22/2010 : Fixed a bug that 
 *                reported an incorrect activation date/time
 *                Brought up to standard.
 * ******************************************************** */
CREATE PROCEDURE [ReportDeviceActivationDetail] (
    @Date DATETIME,
    @TimezoneOffset INT
)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @DayBegin DATETIME, 
        @DayEnd DATETIME, 
        @DaylightOffset INT

SET @TimezoneOffset = -@TimezoneOffset  -- This is done because the Javascript that gets the Offset doesn't apply the sign
SET @DayBegin = DATEADD(MINUTE, @TimezoneOffset, @Date)
SET @DayEnd = DATEADD(DAY, 1, @DayBegin)

select @TimezoneOffset

SELECT ota.TrackerID,
       Devices.[Name], 
       Agency.SFDCAccount AS 'SFDCACCT#',
		   REPLACE(Agency.Agency, ',', ';' ) AS 'Agency',
       DATEADD(MINUTE, @TimezoneOffset, ota.ActivateDate) AS 'ActivateDate',
       Offender.FirstName + ' ' + Offender.LastName AS 'Offender',
       usr.UserName,
       CONVERT(VARCHAR(20), dp4.Propertyvalue) AS 'ICCID',
       netop.[Name] AS 'SimProvider'
FROM OffenderTrackerActivation ota
  LEFT OUTER JOIN Offender ON ota.OffenderID = Offender.OffenderID
  LEFT OUTER JOIN Agency ON Agency.AgencyID = Offender.AgencyID
  LEFT OUTER JOIN [User] usr ON usr.UserID = ota.ModifiedByID
  LEFT OUTER JOIN Gateway.dbo.Devices Devices ON Devices.DeviceID = ota.TrackerID
  INNER JOIN Gateway.dbo.DeviceProperties dp3 ON Devices.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'
  LEFT OUTER JOIN Gateway.dbo.NetworkOperators netop ON netop.MCC + netop.MNC = LEFT(dp3.Propertyvalue,6)
  INNER JOIN Gateway.dbo.DeviceProperties dp4 ON Devices.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8204'
WHERE ota.ActivateDate >= @DayBegin 
  AND ota.ActivateDate < @DayEnd
ORDER BY Agency.Agency, 
         ota.TrackerID
GO

GRANT EXECUTE ON [ReportDeviceActivationDetail] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReportDeviceActivationDetail] TO [db_object_def_viewers]
GO

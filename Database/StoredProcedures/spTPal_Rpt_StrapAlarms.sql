USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_StrapAlarms]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_StrapAlarms]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_StrapAlarms.sql
 * Created On: 04/11/2013
 * Created By: R.Cole
 * Task #:     4049
 * Purpose:    Populate strap alarm report               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_StrapAlarms] (
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @UTCOffset INT,
        @Now DATETIME

SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
SET @Now = GETDATE()                    -- Only get the date once

-- // Account for NULL Params // --
IF @StartDate IS NULL
  BEGIN
    SET @StartDate = DATEADD(DAY, -1, @Now)
    SET @EndDate = @Now
  END 
   
-- // Main Query // --
SELECT DISTINCT Offender.LastName AS Expediente,
       Offender.FirstName AS Interno,
       dp1.propertyvalue AS Dispositivo,
       Agency.Agency AS Agencia,
       Officer.FirstName + ' ' + Officer.LastName AS Oficial,
       EventType.AbbrEveventType AS Tipo_de_Alerta,
       COUNT(Alarm.AlarmID) AS Cantidad
FROM TrackerPal.dbo.Alarm
	INNER JOIN TrackerPal.dbo.EventType ON Alarm.EventTypeID = EventType.EventTypeID
	INNER JOIN TrackerPal.dbo.Offender ON Alarm.OffenderID = Offender.OffenderID
	INNER JOIN TrackerPal.dbo.OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
	INNER JOIN TrackerPal.dbo.Agency ON Offender.AgencyID = Agency.AgencyID
	INNER JOIN TrackerPal.dbo.Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
	INNER JOIN TrackerPal.dbo.Officer ON Offender_Officer.OfficerID = Officer.OfficerID
	INNER JOIN Gateway.dbo.DeviceProperties dp1 ON Alarm.TrackerID = dp1.DeviceID AND dp1.PropertyID = '8012' --S/N
WHERE DATEADD(MINUTE, @UTCOffset, Alarm.EventDisplayTime) BETWEEN @StartDate AND @EndDate
	AND Agency.AgencyID = 35
	AND EventType.EventTypeID = 65
GROUP BY Offender.LastName,
         Offender.FirstName,
         dp1.PropertyValue,
         Agency.Agency,
         Officer.FirstName + ' ' + Officer.LastName,
         EventType.AbbrevEventType
ORDER BY Offender.LastName
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_StrapAlarms] TO db_dml;
GO
USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_QualityOfService]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_QualityOfService]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_QualityOfService.sql
 * Created On: 8/2/2011
 * Created By: R.Cole
 * Task #:     2530
 * Purpose:                   
 *
 * Modified By: R.Cole - 05/06/2013: Per, #4113, Corrected an 
 *  issue where the incorrect agency assignment was being 
 *  returned.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_QualityOfService] (
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS   
/* ******************************** Event Parameter Key ******************************************** *
  Event Parameter   Event Parameter Hex  Event Parameter Name                               Threshold
         16              0x0010          RTR_EVENTPARAM_DEV_NOTICE_GPS_FAILURE	                2
         17              0x0011          RTR_EVENTPARAM_DEV_NOTICE_MODEM_FAILURE	              2
         32              0x0020          RTR_EVENTPARAM_DEV_NOTICE_STUCK_BUTTON	                2
        259              0x0103          RTR_EVENTPARAM_DEV_NOTICE_GPS_FW_FLASH_READ	          1
        260              0x0104          RTR_EVENTPARAM_DEV_NOTICE_GPS_FW_CORRUPT	              1
        261              0x0105          RTR_EVENTPARAM_DEV_NOTICE_GPS_BOOTSTRAP	              1
        262              0x0106          RTR_EVENTPARAM_DEV_NOTICE_GPS_RAM_CHECKSUM	            1
        264              0x0108          RTR_EVENTPARAM_DEV_NOTICE_GPS_TIME_JUMP	              1
        265              0x0109          RTR_EVENTPARAM_DEV_NOTICE_GPS_FW_BAD_RESPONSE	        1
        512              0x0200          RTR_EVENTPARAM_DEV_NOTICE_MODEM_REBOOT	               30           
        513              0x0201          RTR_EVENTPARAM_DEV_NOTICE_MODEM_HW_INIT	              -
        514              0x0202          RTR_EVENTPARAM_DEV_NOTICE_MODEM_CPIN_TOUT	            5
        517              0x0205          RTR_EVENTPARAM_DEV_NOTICE_MODEM_RETRY_COUNT_EX         2
 * *************************************************************************************************** */

/* *** DEV USE ONLY *** 
DECLARE @StartDate DATETIME,
        @EndDate DATETIME
SET @StartDate = NULL
SET @EndDate = NULL
*/
 
DECLARE @GatewayName VARCHAR(1024)
SET @GatewayName = (SELECT PropertyValue FROM Gateway.dbo.GatewayProperties WHERE PropertyID = '2000')
 
-- // Account for NULL Params // --
IF ((@StartDate IS NULL) OR (@EndDate IS NULL))
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, GETDATE())
    SET @EndDate = GETDATE()
  END
  
-- // Main Query // --
SELECT Devices.DeviceID,
       Devices.Name AS SerialNumber,
       evt.EventParameter,       
       SUBSTRING(CONVERT(VARBINARY(4),evt.EventParameter),3,2) AS 'EventParameter Hex',
       CASE WHEN (evt.EventID = 160 AND evt.EventParameter = 16) THEN 'DEV_NOTICE_GPS_FAILURE' -- Left RTR_EVENTPARAM_ off the names
            WHEN (evt.EventID = 160 AND evt.EventParameter = 17) THEN 'DEV_NOTICE_MODEM_FAILURE'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 32) THEN 'DEV_NOTICE_STUCK_BUTTON'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 259) THEN 'DEV_NOTICE_GPS_FW_FLASH_READ'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 260) THEN 'DEV_NOTICE_GPS_FW_CORRUPT'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 261) THEN 'DEV_NOTICE_GPS_BOOTSTRAP'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 262) THEN 'DEV_NOTICE_GPS_RAM_CHECKSUM' 
            WHEN (evt.EventID = 160 AND evt.EventParameter = 264) THEN 'DEV_NOTICE_GPS_TIME_JUMP'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 265) THEN 'DEV_NOTICE_GPS_FW_BAD_RESPONSE'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 512) THEN 'DEV_NOTICE_MODEM_REBOOT'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 514) THEN 'DEV_NOTICE_MODEM_CPIN_TOUT'
            WHEN (evt.EventID = 160 AND evt.EventParameter = 517) THEN 'DEV_NOTICE_MODEM_RETRY_COUNT_EX'
            WHEN (evt.EventID = 122 AND evt.EventParameter = 1) THEN 'INBOUND_CALL_DROP_UNAUTH'
            WHEN (evt.EventID = 122 AND evt.EventParameter = 2) THEN 'INBOUND_CALL_DROP_NOCALLERID'
       END AS 'EventParameterName',
       (CASE WHEN (evt.EventParameter IN (17,259,260,261,262,265,514,517)) THEN 1  
                WHEN (evt.EventParameter IN (1,16,32,264)) THEN 2
                WHEN (evt.EventParameter IN (2,512)) THEN 3
        END) AS 'Severity'
INTO #tmpQoS
FROM Gateway.dbo.[Events] evt WITH (NOLOCK)
  INNER JOIN Gateway.dbo.Devices Devices WITH (NOLOCK) ON evt.DeviceID = Devices.DeviceID
WHERE evt.EventID IN (122, 160)
  AND evt.EventParameter <> 0
  AND evt.TransmittedTime BETWEEN @StartDate AND @EndDate
  AND evt.EventParameter IN (1,2,16,17,32,259,260,261,262,264,265,512,514,517)

-- // Get Final Results // --
SELECT DISTINCT DeviceID,
       SerialNumber,
       EventParameterName,
       Severity,
       (CASE qos.EventParameter WHEN 1 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 1)
                                WHEN 2 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 2) 
                                WHEN 16 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 16)       
                                WHEN 17 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 17)
                                WHEN 32 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 32)
                                WHEN 259 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 259)
                                WHEN 260 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 260)
                                WHEN 261 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 261)
                                WHEN 262 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 262)
                                WHEN 264 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 264)
                                WHEN 265 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 265)
                                WHEN 512 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 512)
                                WHEN 514 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 514)
                                WHEN 517 THEN (SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 517)
        END) AS 'Occurrences',
        Agency.Agency,
        Officer.LastName + ', ' + Officer.FirstName AS Officer,
        Offender.LastName + ', ' + Offender.FirstName AS Offender,
        @StartDate AS StartDate,
        @EndDate AS EndDate,
        @GatewayName AS Gateway
FROM #tmpQoS qos
  INNER JOIN OffenderTrackerActivation ota (NOLOCK) ON qos.DeviceID = ota.TrackerID
  INNER JOIN Tracker WITH (NOLOCK) ON ota.TrackerID = Tracker.TrackerID
  INNER JOIN Agency WITH (NOLOCK) ON Tracker.AgencyID = Agency.AgencyID
  INNER JOIN Offender WITH (NOLOCK) ON ota.OffenderID = Offender.OffenderID
  INNER JOIN Offender_Officer WITH (NOLOCK) ON Offender.OffenderID = Offender_Officer.OffenderID
  INNER JOIN Officer WITH (NOLOCK) ON Offender_Officer.OfficerID = Officer.OfficerID
WHERE (((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 1) >= 3)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 2) >= 2)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 16) >= 2)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 17) >= 2)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 32) >= 2)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 259) >= 1)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 260) >= 1)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 261) >= 1)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 262) >= 1)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 264) >= 1)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 265) >= 1)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 512) >= 30)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 514) >= 5)
   OR ((SELECT COUNT (*) FROM #tmpQoS q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 517) >= 2))
  AND Tracker.CreatedDate < @StartDate                           
	AND (Tracker.ModifiedDate >= @EndDate OR Tracker.Deleted = 0)
  AND ota.TrackerActivationID = (SELECT MAX(TrackerActivationID) FROM TrackerPal.dbo.OffenderTrackerActivation ta WHERE ta.TrackerID = ota.TrackerID) 
ORDER BY Severity DESC,
         SerialNumber,
         Agency.Agency,
         Officer.LastName + ', ' + Officer.FirstName,
         Offender.LastName + ', ' + Offender.FirstName

DROP TABLE #tmpQoS
GO
 
-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_QualityOfService] TO db_dml;
GO
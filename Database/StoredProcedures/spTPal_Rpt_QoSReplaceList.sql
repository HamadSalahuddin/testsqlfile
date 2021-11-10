USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_QoSReplaceList]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_QoSReplaceList]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_QoSReplaceList.sql
 * Created On: 04/12/2013         
 * Created By: R.Cole
 * Task #:     4050
 * Purpose:    Return S/N's of Islas devices needing replacement
 *             due to failing the QoS report.               
 *
 * Modified By: R.Cole - 04/19/2013: Tweaked, replaced temp
 *              table with table variable so SSRS would stop
 *              complaining.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_QoSReplaceList] (
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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
        513              0x0201          RTR_EVENTPARAM_DEV_NOTICE_MODEM_HW_INIT	              5
        514              0x0202          RTR_EVENTPARAM_DEV_NOTICE_MODEM_CPIN_TOUT	            5
        517              0x0205          RTR_EVENTPARAM_DEV_NOTICE_MODEM_RETRY_COUNT_EX         2
 * *************************************************************************************************** */
/* ***************************************************************************************************
    Per Gary's requirements, we only want to display devices that meet the following conditions:
    1) if the device has over 100 count of any event listed under "Event Parameter Name"
    2) If the device has any event from the following list of critical error conditions (regardless of count)
       DEV_NOTICE_GPS_Failure, 
       DEV_NOTICE_MODEM_CPIN_TOUT, 
       DEV_NOTICE_MODEM_FAILURE, 
       DEV_NOTICE_STUCK_BUTTON
 * *************************************************************************************************** */

DECLARE @QoSLite TABLE (
  [DeviceID] INT,
  [SerialNumber] NVARCHAR(20),
  [EventID] INT,
  [EventParameter] INT, 
  [EventTime] BIGINT,
  UNIQUE CLUSTERED (DeviceID, EventID, EventTime)       -- index for speed

)
 
-- // Account for NULL Params // --
IF ((@StartDate IS NULL) OR (@EndDate IS NULL))
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, GETDATE())
    SET @EndDate = GETDATE()
  END
   
-- // Main Query // --
INSERT INTO @QoSLite (
  DeviceID,
  SerialNumber,
  EventID,
  EventParameter,
  EventTime
)
SELECT Devices.DeviceID,
       Devices.Name AS SerialNumber,
       evt.EventID,
       evt.EventParameter,
       evt.EventTime
FROM Gateway.dbo.[Events] evt WITH (NOLOCK)
  INNER JOIN Gateway.dbo.Devices Devices WITH (NOLOCK) ON evt.DeviceID = Devices.DeviceID
WHERE evt.TransmittedTime BETWEEN @StartDate AND @EndDate
  AND evt.EventID = 160
  AND evt.EventParameter IN (16,17,32,259,260,261,262,264,265,512,513,514,517)

-- // Get Final Results // --
SELECT DISTINCT DeviceID,
       SerialNumber
FROM @QoSLite qos
  INNER JOIN Tracker WITH (NOLOCK) ON qos.DeviceID = Tracker.TrackerID
--  INNER JOIN TrackerAssignment WITH (NOLOCK) ON Tracker.TrackerID = TrackerAssignment.TrackerID
  INNER JOIN OffenderTrackerActivation WITH (NOLOCK) on Tracker.TrackerID = OffenderTrackerActivation.TrackerID
  INNER JOIN Agency WITH (NOLOCK) ON Tracker.AgencyID = Agency.AgencyID  
WHERE (((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 16) >= 2)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 17) >= 2)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 32) >= 10)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 259) >= 1)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 260) >= 1)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 261) >= 1)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 262) >= 100)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 264) >= 100)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 265) >= 100)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 512) >= 100)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 513) >= 5)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 514) >= 10)
   OR ((SELECT COUNT (*) FROM @QoSLite q WHERE q.DeviceID = qos.DeviceID AND q.EventParameter = 517) >= 100))
--   AND TrackerAssignment.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) 
--                                                FROM TrackerPal.dbo.TrackerAssignment t 
--                                                WHERE t.TrackerID = qos.DeviceID
--                                                  AND t.TrackerAssignmentTypeID = 1)
   AND OffenderTrackerActivation.TrackerActivationID = (SELECT MAX(TrackerActivationID)
                                                        FROM OffenderTrackerActivation ota
                                                        WHERE ota.TrackerID = qos.DeviceID
                                                          AND ota.DeactivateDate IS NULL)
  AND Agency.AgencyID = 35                                                                      -- SEGOB - Laguna del Toro 
ORDER BY SerialNumber ASC
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_QoSReplaceList] TO db_dml;
GO


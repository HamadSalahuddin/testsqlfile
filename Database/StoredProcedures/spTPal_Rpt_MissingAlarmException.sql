USE [TrackerPal]															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_MissingAlarmException]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_MissingAlarmException]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_MissingAlarmException.sql
 * Created On: 08/15/2011
 * Created By: R.Cole
 * Task #:     2258 
 * Purpose:    Populates an automate Exception report that
 *             identifies alarms that did not make it to 
 *             the Monitor Center screen.               
 *
 * Modified By: R.Cole - 8/16/2011: Rewrote from scratch.
 *              R.Cole - 11/09/2011: Adjusted for DST, -7
 *              R.Cole - 03/14/2012: Adjusted back to -6 
 *              R.Cole - 04/25/2012: Added code to store
 *              the missed alarms for alarming and research
 *              R.Cole - 05/08/2012: Added ProtocolSet name
 *                per #3340
 *              R.Cole - 11/08/2012: Adjusted for DST, -7
 *              R.Cole - Added DST change handling code.
 *              R.Cole - Increased performance, added checks
 *                to eliminate stacked alarms.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_MissingAlarmException] (
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Truncate INT,
        @UTCOffset INT

SET @Truncate = (SELECT COUNT(*) FROM [dbo].[MissingAlarms])

SET @UTCOffset = TrackerPal.dbo.fnGetMSTOffset(8)  -- MountainTime

-- // Clean up old data // --
IF ISNULL(@Truncate,-1) > 0
  TRUNCATE TABLE [dbo].[MissingAlarms]
        
-- // Account for NULL params // --
IF @StartDate IS NULL
  BEGIN
    SET @StartDate = DATEADD(HOUR, -2, GETDATE())
    SET @EndDate = GETDATE()
  END  

INSERT INTO [dbo].[MissingAlarms] (AlarmID, EventDisplayTime, OffenderID, TrackerID, AbbrevEventType)
  SELECT DISTINCT Alarm.AlarmID,
         Alarm.EventDisplayTime,
         Alarm.OffenderID,
         Alarm.TrackerID,
         EventType.AbbrevEventType
  FROM Alarm WITH (NOLOCK)
   INNER JOIN EventType  WITH (NOLOCK) ON Alarm.EventTypeID = EventType.EventTypeID
  WHERE EventDisplayTime > DATEADD(HOUR, -2, GETDATE())
--  WHERE Alarm.EventDisplayTime BETWEEN @StartDate AND @EndDate
    AND Alarm.EventTypeID NOT IN (256,257,258)  
    AND Alarm.AlarmID NOT IN (SELECT AlarmID FROM AlarmNote WITH (NOLOCK))
    AND Alarm.AlarmID NOT IN (SELECT AlarmID FROM AlarmAssignmentStatus WITH (NOLOCK))
    AND Alarm.AlarmID NOT IN (SELECT AlarmID FROM rprtAlarmMonitorCenterGrid WITH (NOLOCK))
    AND Alarm.AlarmID NOT IN (SELECT AlarmID FROM rprtAlarmMonitorCenterSubGrid WITH (NOLOCK))
    AND Alarm.AlarmGroupID IS NULL
 
-- // Main Query // --
SELECT DISTINCT mia.AlarmID AS AlarmID,
       DATEADD(MI, @UTCOffset, mia.EventDisplayTime) AS AlarmTime,
       mia.AbbrevEventType AS Alarm,
       Agency.Agency AS Agency,
       Officer.FirstName + ' ' + Officer.LastName AS Officer,
       Offender.Firstname + ' ' + Offender.LastName AS Offender,
       dp.PropertyValue AS Device,
       AlarmProtocolSet.AlarmProtocolSetName,
       CONVERT(CHAR(20), DATEADD(MI, @UTCOffset, @StartDate), 22) AS 'StartDate',
       CONVERT(CHAR(20), DATEADD(MI, @UTCOffset, @EndDate), 22) AS 'EndDate'
FROM MissingAlarms mia
--FROM @MissedAlarms mia
  INNER JOIN Offender WITH (NOLOCK) ON mia.OffenderID = Offender.OffenderID
  INNER JOIN Offender_Officer WITH (NOLOCK) ON Offender.OffenderID = Offender_Officer.OffenderID
  INNER JOIN Officer WITH (NOLOCK) ON Offender_Officer.OfficerID = Officer.OfficerID
  INNER JOIN Agency WITH (NOLOCK) ON Offender.AgencyID = Agency.AgencyID
  INNER JOIN Gateway.dbo.DeviceProperties dp (NOLOCK) ON mia.TrackerID = dp.DeviceID AND dp.PropertyID = '8012'
  INNER JOIN Offender_AlarmProtocolSet WITH (NOLOCK) ON Offender.OffenderID = Offender_AlarmProtocolSet.OffenderID
  INNER JOIN AlarmProtocolSet WITH (NOLOCK) ON Offender_AlarmProtocolSet.AlarmProtocolSetID = AlarmProtocolSet.AlarmProtocolSetID
WHERE Offender_AlarmProtocolSet.Deleted = 0
ORDER BY mia.AlarmID ASC
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_MissingAlarmException] TO db_dml;
GO
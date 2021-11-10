USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AlarmSummary]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AlarmSummary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AlarmSummary.sql
 * Created On: 03/04/2013
 * Created By: R.Cole
 * Task #:     3940
 * Purpose:    Automated version of the Alarm Summary Report
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AlarmSummary] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @RunDate CHAR(10),
        @UTCOffset INT,
        @StartDate DATETIME,
        @EndDate DATETIME

-- // Set Dates // --
SET @StartDate = DATEADD(HOUR, -12, GETDATE())
SET @EndDate = GETDATE()

-- SET UTCOffset // --
SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
        
-- // Set Report RunDate // --
SET @RunDate = CONVERT(CHAR(10),DATEADD(mi,@UTCOffset,GETDATE()),103)   
   
-- // Main Query // --
SELECT Agency.Agency,
       EventType.AbbrevEventType AS Alarm,
       COUNT(DISTINCT(AlarmID)) AS Alarms,
       @RunDate AS [RunDate],
       RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, DATEADD(MI, @UTCOffset, @StartDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2),DATEPART(MINUTE, DATEADD(MI, @UTCOffset, @StartDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(SECOND, DATEADD(MI, @UTCOffset, @StartDate))),2) AS StartTime,
       RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, DATEADD(MI, @UTCOffset, @EndDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2),DATEPART(MINUTE, DATEADD(MI, @UTCOffset, @EndDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(SECOND, DATEADD(MI, @UTCOffset, @EndDate))),2) AS EndTime
FROM Alarm WITH (NOLOCK)
  INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
  INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
  INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
WHERE Agency.AgencyID IN (20,21,22,23,24,30)
  AND Alarm.EventDisplayTime BETWEEN @StartDate AND @EndDate
GROUP BY EventType.AbbrevEventType,
         Agency
ORDER BY Agency,
         EventType.AbbrevEventType
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AlarmSummary] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AlarmDetailWithOperator]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AlarmDetailWithOperator]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AlarmDetailWithOperator.sql
 * Created On: 03/05/2013
 * Created By: R.Cole
 * Task #:     3940
 * Purpose:    Return data to the hourly Alarm Detail with
 *             Operator Report.
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AlarmDetailWithOperator] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Declare Var's // --
DECLARE @RunDate CHAR(10),
        @UTCOffset INT,
        @StartDate DATETIME,
        @EndDate DATETIME

-- // Set Dates // --
SET @StartDate = DATEADD(HOUR, -1, GETDATE())
SET @EndDate = GETDATE()

-- SET UTCOffset // --
SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
        
-- // Set Report RunDate // --
SET @RunDate = CONVERT(CHAR(10),DATEADD(mi,@UTCOffset,GETDATE()),103)         
   
-- // Main Query // --
SELECT DISTINCT Alarm.AlarmID,
       EventType.AbbrevEventType AS Alarm,
       CONVERT(CHAR(10), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 103) AS AlarmDate,
       RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, DATEADD(MI, @UTCOffset, Alarm.EventDisplayTime))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2),DATEPART(MINUTE, DATEADD(MI, @UTCOffset, Alarm.EventDisplayTime))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(SECOND, DATEADD(MI, @UTCOffset, Alarm.EventDisplayTime))),2) AS AlarmTime,
       Operator.LastName + ', ' + Operator.FirstName AS Operator,
       Offender.LastName,
       Offender.FirstName AS OffenderName,
       @RunDate AS [RunDate],
       RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, DATEADD(MI, @UTCOffset, @StartDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2),DATEPART(MINUTE, DATEADD(MI, @UTCOffset, @StartDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(SECOND, DATEADD(MI, @UTCOffset, @StartDate))),2) AS StartTime,
       RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, DATEADD(MI, @UTCOffset, @EndDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2),DATEPART(MINUTE, DATEADD(MI, @UTCOffset, @EndDate))),2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(SECOND, DATEADD(MI, @UTCOffset, @EndDate))),2) AS EndTime
FROM Alarm WITH (NOLOCK)
  INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
  INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
  INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
  INNER JOIN AlarmAssignment ON Alarm.AlarmID = AlarmAssignment.AlarmID
  INNER JOIN Operator ON AlarmAssignment.AssignedToID = Operator.OperatorID 
WHERE Agency.AgencyID IN (20,21,22,23,24,30)
  AND Alarm.EventDisplayTime BETWEEN @StartDate AND @EndDate
GROUP BY Offender.LastName,
         Offender.FirstName,
         EventType.AbbrevEventType,
         Operator.LastName + ', ' + Operator.FirstName,
         Alarm.AlarmID,
         Alarm.EventDisplayTime
ORDER BY Alarm.AlarmID
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AlarmDetailWithOperator] TO db_dml;
GO
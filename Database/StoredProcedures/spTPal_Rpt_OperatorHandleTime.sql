USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_OperatorHandleTime]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_OperatorHandleTime]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_OperatorHandleTime.sql
 * Created On: 10/26/2011         
 * Created By: R.Cole  
 * Task #:     2872
 * Purpose:    Return data for the Operator Handle Time Report
 *             Originally code by A.Harris               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_OperatorHandleTime] (
  @StartDate DATETIME,
  @EndDate DATETIME
) 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Main Query // --
SELECT DISTINCT DATEADD(HOUR, -6, Alarm.EventDisplayTime) AS AlarmTimeMDT,
       CONVERT(CHAR(25), DATEADD(HOUR, -6, Accepted.AssignedDate), 101) AS AcceptedDate,
       100 * DATEPART(HOUR, DATEADD(MINUTE,DATEDIFF(MINUTE, 0, DATEADD(HOUR, -6, Accepted.AssignedDate)) / 30 * 30, 0)) + DATEPART(MINUTE, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, DATEADD(HOUR, -6, Accepted.AssignedDate)) / 30 * 30, 0)) AS AcceptedHalfHour,
       Operator.FirstName + ' ' + Operator.LastName AS Operator,
       EventType.AbbrevEventType AS AlarmType,
       DATEDIFF(SECOND, DATEADD(HOUR, -6, Accepted.AssignedDate), DATEADD(HOUR, -6, Completed.AssignedDate)) AS HandleTime
FROM Alarm
  INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
  LEFT OUTER JOIN AlarmAssignment Accepted ON Alarm.AlarmID = Accepted.AlarmID
		AND Accepted.AssignedDate = (SELECT MIN(AssignedDate) 
		                             FROM AlarmAssignment aad 
		                             WHERE aad.AlarmID = Alarm.AlarmID
			                             AND aad.AlarmAssignmentStatusID = 2)
  LEFT OUTER JOIN AlarmAssignment Completed ON Alarm.AlarmID = Completed.AlarmID 
		AND Completed.AssignedDate = (SELECT MAX(AssignedDate) 
		                              FROM AlarmAssignment aadmax 
		                              WHERE aadmax.AlarmID = Alarm.AlarmID
			                              AND aadmax.AlarmAssignmentStatusID = 4)
  INNER JOIN Operator ON Accepted.AssignedToID = Operator.UserID
WHERE DATEADD(HOUR, -6, Accepted.AssignedDate) >= @StartDate
	AND DATEADD(HOUR, -6, Accepted.AssignedDate) < @EndDate
ORDER BY CONVERT(CHAR(25), DATEADD(HOUR, -6, Accepted.AssignedDate),101)
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_OperatorHandleTime] TO db_dml;
GO
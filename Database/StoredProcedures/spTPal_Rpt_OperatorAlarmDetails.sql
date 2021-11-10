USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_OperatorAlarmDetails]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_OperatorAlarmDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_OperatorAlarmDetails.sql
 * Created On: 05/05/2011         
 * Created By: R.Cole
 * Task #:     #1843
 * Purpose:    Detailed Operator Alarm Report
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_OperatorAlarmDetails] (
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;

/* ******** Dev Use Only ********* 
DECLARE @StartDate DATETIME,
        @EndDate DATETIME
        
SET @StartDate = NULL
SET @EndDate = NULL
* ******* End Dev Use ********* */

-- // Handle NULL Dates // --
IF @StartDate IS NULL
  SET @StartDate = DATEADD(DD,-1,GETDATE())
  
IF @EndDate IS NULL
  SET @EndDate = GETDATE()
   
-- // Main Query // --
SELECT DISTINCT Operator.FirstName + ' ' + Operator.LastName AS Operator,
       Agency.Agency AS Agency,
       Officer.FirstName + ' ' + Officer.LastName AS Officer,
       Offender.FirstName + ' ' + Offender.LastName AS Offender,
       dp.PropertyValue AS Device,
       EventType.AbbrevEventType AS AlarmType,
       dbo.fnUTCtoMST(Alarm.EventDisplayTime) AS AlarmTime
FROM Alarm
	INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
	INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
	INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
	INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
	INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
	LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON Alarm.TrackerID = dp.DeviceID 
	            AND dp.PropertyID = '8012'
	INNER JOIN AlarmAssignment ON Alarm.AlarmID = AlarmAssignment.AlarmID
	INNER JOIN Operator ON AlarmAssignment.AssignedToID = Operator.UserID
WHERE (Alarm.EventDisplayTime >= @StartDate AND Alarm.EventDisplayTime < @EndDate)      
	AND AlarmAssignment.AssignedToID <> 2040
	AND AlarmAssignment.AlarmAssignmentStatusID = 4
ORDER BY dbo.fnUTCtoMST(Alarm.EventDisplayTime)
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_OperatorAlarmDetails] TO db_dml;
GO
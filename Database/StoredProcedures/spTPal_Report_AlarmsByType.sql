USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Report_AlarmsByType]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Report_AlarmsByType]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Report_AlarmsByType.sql
 * Created On: 08/24/2010
 * Created By: R.Cole  
 * Task #:     #1257
 * Purpose:    Automated report of the number of alarms by
 *             type over a rolling 4 hour time block.               
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Report_AlarmsByType]
AS
SET NOCOUNT ON;
DECLARE @StartDate DATETIME,
        @EndDate DATETIME        
        
SET @StartDate = DATEADD(HOUR, -4, GETDATE())
SET @EndDate = GETDATE()
   
-- // Main Query // --
SELECT EventType.AbbrevEventType AS 'Alarm',
       COUNT(AlarmID) AS 'Count'
FROM Alarm
  INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
WHERE Alarm.EventDisplayTime BETWEEN @StartDate AND @EndDate
GROUP BY EventType.AbbrevEventType
ORDER BY EventType.AbbrevEventType
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Report_AlarmsByType] TO db_dml;
GO

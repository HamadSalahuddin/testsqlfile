USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Report_AlarmsByTypeByOffender]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Report_AlarmsByTypeByOffender]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Report_AlarmsByTypeByOffender.sql
 * Created On: 08/24/2010
 * Created By: R.Cole  
 * Task #:     #1257
 * Purpose:    Automated report of the number of alarms by
 *             type, by offender over a rolling 4 hour time 
 *             block.               
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Report_AlarmsByTypeByOffender]
AS
SET NOCOUNT ON;
DECLARE @StartDate DATETIME,
        @EndDate DATETIME        
        
SET @StartDate = DATEADD(HOUR, -4, GETDATE())
SET @EndDate = GETDATE()
   
-- // Main Query // --
SELECT Offender.FirstName + ' ' + Offender.LastName AS 'Offender',
--       EventType.AbbrevEventType AS 'Alarm',
       COUNT(AlarmID) AS 'Count'
FROM Alarm
  INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
  INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
WHERE Alarm.EventTypeID = 65
  AND Alarm.EventDisplayTime BETWEEN @StartDate AND @EndDate
GROUP BY --EventType.AbbrevEventType,
         Offender.FirstName + ' ' + Offender.LastName
ORDER BY Offender.FirstName + ' ' + Offender.LastName         
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Report_AlarmsByTypeByOffender] TO db_dml;
GO

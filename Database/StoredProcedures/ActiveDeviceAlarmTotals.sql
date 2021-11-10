/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ActiveDeviceAlarmTotals]

@StartDate DateTime,
@EndDate DateTime

AS
Delete FROM TrackerPal.dbo.ActiveDevicesByDay


DECLARE Activations CURSOR FOR
Select Convert(varchar(30),date,101)
From DateDimension 
Where date between @startdate and @enddate


OPEN Activations

	DECLARE @date DateTime
	FETCH NEXT FROM Activations 
	INTO @date

	WHILE @@FETCH_STATUS = 0

	BEGIN
INSERT INTO [TrackerPal].[dbo].[ActiveDevicesByDay]
           ([Date]
           ,[Total])

Select
   @date,
   Count(*)
   From Offendertrackeractivation
   Where (@date between DATEADD(mi,-360,activatedate) And DATEADD(mi,-360,deactivatedate)) 
   OR (DATEADD(mi,-360,activatedate)<@Date AND Deactivatedate IS NULL)
	FETCH NEXT FROM Activations
	INTO @Date
	END

CLOSE Activations
DEALLOCATE Activations


select 
CONVERT(varchar(25),abd.date,101) As 'Date',
MAX(abd.total)As TotalActiveDevices,
SUM(1) AS 'Total Alarms' 
From TrackerPal.dbo.ActiveDevicesByDay abd
Join Alarm a ON CONVERT(varchar(25),DATEADD(mi,-360,a.EventDisplayTime),101)= CONVERT(varchar(25),abd.date,101)
GROUP BY CONVERT(varchar(25),abd.date,101)
Order BY CONVERT(varchar(25),abd.date,101)





GO
GRANT EXECUTE ON [ActiveDeviceAlarmTotals] TO [db_dml]
GO

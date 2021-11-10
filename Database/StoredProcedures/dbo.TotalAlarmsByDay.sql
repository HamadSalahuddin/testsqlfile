/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TotalAlarmsByDay]
@StartDate DateTime,
@EndDate DateTime

--SET @StartDate = '2008-09-01'
--SET @EndDate = '2008-10-01'
--Set @Eventid = 256
AS
SELECT
CONVERT(CHAR(10),DATEADD(mi,-360,a.Eventdisplaytime),110)  AS Date

,SUM(CASE When a.eventtypeID = 21 THEN 1
ELSE 0 END) AS 'Ext BatTmout'

,SUM(CASE When a.eventtypeID = 25 THEN 1
ELSE 0 END) AS 'Bat Crit'

,SUM(CASE When a.eventtypeID = 65 THEN 1
ELSE 0 END) AS 'StrapOptical'

,SUM(CASE When a.eventtypeID = 44 THEN 1
ELSE 0 END) AS 'Incl Violate'

,SUM(CASE When a.eventtypeID = 45 THEN 1
ELSE 0 END) AS 'Incl Cmplnce'

,SUM(CASE When a.eventtypeID = 36 THEN 1
ELSE 0 END) AS 'Excl Violate'

,SUM(CASE When a.eventtypeID = 37 THEN 1
ELSE 0 END) AS 'Excl Cmplnce'

,SUM(CASE When a.eventtypeID = 177 THEN 1
ELSE 0 END) AS 'eBeaconMoved'

,SUM(CASE When a.eventtypeID = 182 THEN 1
ELSE 0 END) AS 'eBeaconBatCrit'

,SUM(CASE When a.eventtypeID = 194 THEN 1
ELSE 0 END) AS 'eArrestViol'

,SUM(CASE When a.eventtypeID = 195 THEN 1
ELSE 0 END) AS 'eArrestComply'

,SUM(CASE When a.eventtypeID = 210 THEN 1
ELSE 0 END) AS 'Batt Crit-TP2'

,SUM(CASE When a.eventtypeID = 211 THEN 1
ELSE 0 END) AS 'Batt Crit Esc-TP2'

,SUM(CASE When a.eventtypeID = 212 THEN 1
ELSE 0 END) AS 'Shutdown Now-TP2'

,SUM(CASE When a.eventtypeID = 26 THEN 1
ELSE 0 END) AS 'Shutdown Pend'

,SUM(CASE When a.eventtypeID = 256 THEN 1
ELSE 0 END) AS 'NoEventTimeout'

,SUM(CASE When a.eventtypeID = 258 THEN 1
ELSE 0 END) AS 'NoEventTimeoutEsc'

,SUM(CASE When a.eventtypeID = 257 THEN 1
ELSE 0 END) AS 'CommResumed'

,SUM(1) AS 'Total Alarms' 

From Alarm a WITH (NOLOCK)
INNER JOIN Eventtype et ON et.eventtypeid = a.eventtypeid
Where DATEADD(mi,-360,EventDisplayTime) BETWEEN @StartDate AND @EndDate 


GROUP BY 
CONVERT(CHAR(10),DATEADD(mi,-360,a.Eventdisplaytime),110)

Order BY Date



GO
GRANT EXECUTE ON [TotalAlarmsByDay] TO [db_dml]
GO

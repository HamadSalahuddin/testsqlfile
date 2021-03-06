/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spNewBillingReportByagency]
--DECLARE
@StartDate DATETIME,
@EndDate DATETIME,
@AgencyID INT
--SET @StartDate = '2008-05-01'
--SET @EndDate = '2008-12-16'
--SET @Agencyid = 868

AS
Select
a.SFDCAccount AS 'SFDCACCT#'
,a.agency
,ofi.FirstName+' '+Ofi.LastName AS 'Officer Name'
,o.FirstName+' '+o.LastName As 'OffenderName'
,acc.id As 'Customerid'
--,dp.uniqueid As 'trackerNumber'
,dp1.propertyvalue AS 'DeviceSerial'
,DATEADD(mi,tz.UtcOffset,ota.ActivateDate) As 'ActivateDate'
,DATEADD(mi,tz.UTCOffset,ota.deactivatedate) AS 'DeactivateDate'
,(CASE
WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) > @StartDate AND ota.DeactivateDate IS NOT NULL AND DATEADD(mi,tz.UTCOffset,ota.DeactivateDate) < @EndDate
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, DATEADD(mi,tz.UTCOffset,ota.activatedate))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,ota.activatedate))*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,ota.activatedate)))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,ota.DeactivateDate)))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,ota.DeactivateDate)))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,ota.DeactivateDate)))))
		+ (CASE WHEN ((DATEPART(mi, DATEADD(mi,tz.UTCOffset,ota.DeactivateDate))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,ota.DeactivateDate))*60))/60.0 >= 2 THEN 1 ELSE 0 END)

WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) > @StartDate AND DeactivateDate IS NOT NULL AND DATEADD(mi,tz.UTCOffset,ota.DeactivateDate) > @EndDate
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, DATEADD(mi,tz.UTCOffset,ota.activatedate))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,ota.activatedate))*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,ota.activatedate)))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(@EndDate))+'.'+CONVERT(varchar(2),MONTH(@EndDate))+'.'+CONVERT(varchar(2),DAY(@EndDate))))
		+ (CASE WHEN ((DATEPART(mi, @EndDate)+DATEPART(hh, @EndDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END)

WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) > @StartDate AND ota.DeactivateDate IS NULL AND @EndDate > DATEADD(mi,tz.UTCOffset,GETDATE())
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, DATEADD(mi,tz.UTCOffset,ota.activatedate))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,ota.activatedate))*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,ota.activatedate)))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,GETDATE())))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,GETDATE())))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,GETDATE())))))
		+ (CASE WHEN ((DATEPART(mi, DATEADD(mi,tz.UTCOffset,GETDATE()))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,GETDATE()))*60))/60.0 >= 2 THEN 1 ELSE 0 END)

WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) > @StartDate AND ota.DeactivateDate IS NULL AND @EndDate < DATEADD(mi,tz.UTCOffset,GETDATE())
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, DATEADD(mi,tz.UTCOffset,ota.activatedate))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,ota.activatedate))*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,ota.activatedate)))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,ota.activatedate)))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(@EndDate))+'.'+CONVERT(varchar(2),MONTH(@EndDate))+'.'+CONVERT(varchar(2),DAY(@EndDate))))
		+ (CASE WHEN ((DATEPART(mi, @EndDate)+DATEPART(hh, @EndDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END)



WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) < @StartDate AND ota.DeactivateDate IS NOT NULL AND DATEADD(mi,tz.UTCOffset,ota.DeactivateDate) < @EndDate
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, @StartDate)+DATEPART(hh, @StartDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(@StartDate))+'.'+CONVERT(varchar(2),MONTH(@StartDate))+'.'+CONVERT(varchar(2),DAY(@StartDate))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,ota.DeactivateDate)))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,ota.DeactivateDate)))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,ota.DeactivateDate)))))
		+ (CASE WHEN ((DATEPART(mi, DATEADD(mi,tz.UTCOffset,ota.DeactivateDate))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,ota.DeactivateDate))*60))/60.0 >= 2 THEN 1 ELSE 0 END)

WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) < @StartDate AND ota.DeactivateDate IS NOT NULL AND DATEADD(mi,tz.UTCOffset,ota.DeactivateDate) > @EndDate
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, @StartDate)+DATEPART(hh, @StartDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(@StartDate))+'.'+CONVERT(varchar(2),MONTH(@StartDate))+'.'+CONVERT(varchar(2),DAY(@StartDate))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(@EndDate))+'.'+CONVERT(varchar(2),MONTH(@EndDate))+'.'+CONVERT(varchar(2),DAY(@EndDate))))
		+ (CASE WHEN ((DATEPART(mi, @EndDate)+DATEPART(hh, @EndDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END)

WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) < @StartDate AND ota.DeactivateDate IS NULL AND @EndDate > DATEADD(mi,tz.UTCOffset,GETDATE())
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, @StartDate)+DATEPART(hh, @StartDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(@StartDate))+'.'+CONVERT(varchar(2),MONTH(@StartDate))+'.'+CONVERT(varchar(2),DAY(@StartDate))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(DATEADD(mi,tz.UTCOffset,GETDATE())))+'.'+CONVERT(varchar(2),MONTH(DATEADD(mi,tz.UTCOffset,GETDATE())))+'.'+CONVERT(varchar(2),DAY(DATEADD(mi,tz.UTCOffset,GETDATE())))))
		+ (CASE WHEN ((DATEPART(mi, DATEADD(mi,tz.UTCOffset,GETDATE()))+DATEPART(hh, DATEADD(mi,tz.UTCOffset,GETDATE()))*60))/60.0 >= 2 THEN 1 ELSE 0 END)

WHEN DATEADD(mi,tz.UTCOffset,ota.activatedate) < @StartDate AND ota.DeactivateDate IS NULL AND @EndDate < DATEADD(mi,tz.UTCOffset,GETDATE())
	THEN 
		(CASE WHEN ((24*60)-(DATEPART(mi, @StartDate)+DATEPART(hh, @StartDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END) 
		+ DATEDIFF(dd,
			DATEADD(dd,1,CONVERT(varchar(4),YEAR(@StartDate))+'.'+CONVERT(varchar(2),MONTH(@StartDate))+'.'+CONVERT(varchar(2),DAY(@StartDate))),
			DATEADD(dd,0,CONVERT(varchar(4),YEAR(@EndDate))+'.'+CONVERT(varchar(2),MONTH(@EndDate))+'.'+CONVERT(varchar(2),DAY(@EndDate))))
		+ (CASE WHEN ((DATEPART(mi, @EndDate)+DATEPART(hh, @EndDate)*60))/60.0 >= 2 THEN 1 ELSE 0 END)

END)AS 'Active Days'
,(CASE When tb.status = 1 Then 'Billable'
WHEN tb.status = 2 Then 'Non Billable'
ELSE 'N/A'END)AS 'Billable Type'
,(CASE When ota.isdemo = 1 THEN 'DEMO'
ELSE 'Non DEMO'END) AS 'Device Type'
,(CASE WHEN o.OffenderPay = 0 THEN 'False'
ELSE 'True' END)AS 'OffenderPay'
,(CASE WHEN obsoo.Offenderid IS NULL THEN 'False'
ELSE 'True' END)AS 'Curently Earrest'

From Offendertrackeractivation ota
JOIN Offender o ON o.Offenderid = ota.Offenderid
JOIN Officer ofi ON ofi.Officerid = ota.Officerid
JOIN agency a ON o.Agencyid = a.Agencyid
LEFT JOIN accounting acc ON acc.CustomerName = a.Agency
JOIN timezone tz ON tz.timezoneid = a.Timezoneid
JOIN Gateway.dbo.Devices dp ON ota.trackerid = dp.deviceid
LEFT JOIN Gateway.dbo.deviceproperties dp1 ON dp1.deviceid = dp.deviceid and dp1.Propertyid = '8012'
LEFT JOIN Trackerbillable tb ON tb.TrackerBillableID = ota.Billableid
LEFT JOIN OptionalBillingServiceOptionOffender obsoo ON obsoo.Offenderid = o.Offenderid
Where 
	(DATEDIFF(mi, @StartDate, DATEADD(mi,tz.UTCOffset,ota.deactivatedate)) > 120
			AND DATEDIFF(mi,DATEADD(mi,tz.UTCOffset,ota.ActivateDate),DATEADD(mi,tz.UTCOffset,ota.deactivatedate)) > 120
        OR ota.deactivatedate IS NULL)
   AND (DATEADD(mi,tz.UTCOffset,ota.ActivateDate) < @EndDate)
      AND (DATEADD(mi,tz.UTCOffset,ota.deactivatedate) >= @StartDate
			OR DATEADD(mi,tz.UTCOffset,ota.deactivatedate) IS NULL)
--   AND (DATEPART(dy,(DATEADD(mi,tz.UTCOffset,ota.ActivateDate))) != DATEPART(dy,(DATEADD(mi,tz.UTCOffset,ota.DeActivateDate)))
--         OR DATEADD(mi,tz.UTCOffset,ota.deactivatedate) IS NULL
--			OR )
AND a.agencyid = @Agencyid
ORDER By a.agency,'OffenderName',ota.ActivateDate



GO
GRANT EXECUTE ON [spNewBillingReportByagency] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportNoncomDetialInvalid]

 
@Date DateTime

AS
Select 
LEFT([MESSAGE],25) AS IMEI
,receivedtime
into #invalidimei 
from gateway.dbo.InvalidMessages 
Where DATEADD(mi,-420,receivedtime) > @Date 
AND reason =

'The DateTime represented by the string is not supported in calendar System.Globalization.GregorianCalendar.'
OR 
reason =

'Year, Month, and Day parameters describe an un-representable DateTime.'


UPDATE #invalidimei
SET imei = Replace(imei,LEFT(imei,10),'')

SELECT
		   --d.[Name]
		  dp5.PropertyValue AS 'Gateway Serial Number'
      ,nop.[name] AS 'SIM Provider'
		  ,dp2.PropertyValue AS 'APN'
		  ,d.Mostlikelyphonenumber AS 'SIMPhoneNumber'
		  ,d.deviceid
          ,d.uniqueid As 'IMEI'
--		  ,dp1.PropertyValue AS 'IMEI'
		  ,dp4.PropertyValue AS 'ICCID'
		  ,LEFT(dp3.PropertyValue,6) AS 'IMSI'
		  ,gateway.dbo.HexToBigInt(CONVERT(nvarchar,dp8.propertyvalue)) AS 'Firmware'
      ,gateway.dbo.HexToBigInt(CONVERT(nvarchar,dp9.propertyvalue)) AS 'Tracking Duration'
       ,(CASE WHEN st.stateid IS NULL Then ''
				ELSE st.abbreviation END) AS State
             ,(CASE When d.LastEventTime !=0 Then DATEADD(mi,-420,Trackerpal.dbo.Convertlongtodate(d.LastEventTime))
			  ELSE 'N/A' END)As 'LastEvent'

,DATEADD(mi,-420,imei.maxreceived) AS receivedtime

FROM gateway.dbo.devices d WITH (NoLock)
JOIN (Select imei, MAX(receivedtime) AS maxreceived FROM #invalidimei GROUP BY imei) imei on imei.imei = d.uniqueid
JOIN Gateway.dbo.DeviceProperties dp1 ON d.DeviceID = dp1.DeviceID AND dp1.PropertyID = '8205'
JOIN Gateway.dbo.DeviceProperties dp2 ON d.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8210'
JOIN Gateway.dbo.DeviceProperties dp3 ON d.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'
JOIN Gateway.dbo.DeviceProperties dp6 ON d.DeviceID = dp6.DeviceID AND dp6.PropertyID = '8203'
JOIN Gateway.dbo.DeviceProperties dp4 ON d.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8204'
LEFT JOIN Gateway.dbo.DeviceProperties dp5 ON d.DeviceID = dp5.DeviceID AND dp5.PropertyID = '8012'
JOIN Gateway.dbo.DeviceProperties dp7 ON d.DeviceID = dp7.DeviceID AND dp7.PropertyID = '8010'
JOIN Gateway.dbo.DeviceProperties dp8 ON d.DeviceID = dp8.DeviceID AND dp8.PropertyID = '8016'
JOIN Gateway.dbo.deviceproperties dp9 ON dp9.deviceid = d.deviceid AND dp9.propertyid = '8020'
LEFT JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC+nop.MNC = LEFT(dp3.Propertyvalue,6)
Left JOIN Trackerpal.dbo.tracker t ON t.trackerid = d.deviceid and t.deleted = 0
LEFT JOIN Agency ag ON ag.agencyid = t.agencyid
LEFT JOIN State st on st.stateid = ag.stateid
WHERE DateADD(mi,-420,imei.maxreceived) > @Date
ORDER BY 'LASTEVENT'DESC

Drop table #invalidimei


GO
GRANT EXECUTE ON [ReportNoncomDetialInvalid] TO [db_dml]
GO

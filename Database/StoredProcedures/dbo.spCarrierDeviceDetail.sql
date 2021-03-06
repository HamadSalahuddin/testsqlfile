/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spCarrierDeviceDetail]
@CarrierId bigint
AS
Select 
(CASE When nop.[name] Is NULL THEN  'UNKNOWN' ELSE nop.[name] END)As 'Carrier'
,dp5.Propertyvalue As 'DeviceSerialNumber'
,(CASE When t.deleted = 0 THEn ag.Agency ELSE 'None'END)As 'Agency'
,(CASE WHEN d.Lasteventtime != 0 THEN DATEADD(mi,-360,dbo.Convertlongtodate(d.Lasteventtime))
ELSE '' END) As 'LastEvent'
From Gateway.dbo.devices d
LEFT JOIN Gateway.dbo.DeviceProperties dp3 ON d.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'
LEFT JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC+nop.MNC = LEFT(dp3.Propertyvalue,6)
LEFT JOIN Gateway.dbo.DeviceProperties dp5 ON d.DeviceID = dp5.DeviceID AND dp5.PropertyID = '8012'
LEFT JOIN (SELECt trackerId, MAX (Trackeruniqueid) As maxtracker From Trackerpal.dbo.tracker Group BY trackerID)t1 ON t1.trackerid = d.deviceid
LEFt JOIN tracker t ON t.trackeruniqueid = t1.maxtracker 
LEFt JOIN Agency ag ON ag.agencyid = t.agencyid
WHERE 
LEFT(dp3.Propertyvalue,6) = @Carrierid
Order BY 'LastEvent' DESC

GO
GRANT EXECUTE ON [spCarrierDeviceDetail] TO [db_dml]
GO

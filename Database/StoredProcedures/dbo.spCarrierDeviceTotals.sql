/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spCarrierDeviceTotals]
AS
Select 
(CASE When nop.[name] Is NULL THEN  'UNKNOWN' ELSE nop.[name] END)As 'Carrier'
,Count(d.Deviceid)
From Gateway.dbo.devices d
LEFT JOIN Gateway.dbo.DeviceProperties dp3 ON d.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'
LEFT JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC+nop.MNC = LEFT(dp3.Propertyvalue,6)
GROUP BY 
nop.[Name]
Order BY nop.[Name]
GO
GRANT EXECUTE ON [spCarrierDeviceTotals] TO [db_dml]
GO

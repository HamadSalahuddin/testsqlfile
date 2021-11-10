/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DeviceCarrierDetail]
@CarrierId bigint
AS
Select
d.uniqueid As 'IMEI'
,dp.Propertyvalue As 'Deviceserial'
,dp4.PropertyValue AS 'ICCID'
,nop.[Name] As 'Carrier'
,(Case When ag.Agency is NULL THEN '' ELSE ag.Agency ENd)As 'Assigned Agency'
,(CASE WHEN ofi.officerid IS NOT NULL THEN ofi.firstname+' '+ofi.LastName ELSE '' ENd)As 'AssignedOfficer'
,(CASE when o.offenderid is NOT NULL THEN o.FirstName+' '+o.LastName
   ELSE '' END)AS 'Offender'
,(CASE When st.stateid IS NULL THEN '' ELSE st.Abbreviation ENd) AS 'State'
       ,(CASE When d.LastEventTime !=0 Then CONVERT(char(25),DATEADD(mi,-420,Trackerpal.dbo.Convertlongtodate(d.LastEventTime)),101)
			  ELSE 'N/A' END)As 'LastEvent'
,(CASE When d.LastEventTime !=0 Then DateDIFF(dd,Trackerpal.dbo.convertlongtodate(d.lasteventtime),Getdate())
			  ELSE 'N/A' END)As 'DaysIncative'
From Gateway.dbo.devices d
JOIN Gateway.dbo.deviceproperties dp ON dp.deviceid = d.deviceid ANd dp.Propertyid = '8012'
LEFt JOIN tracker t ON t.trackerid = d.deviceid and t.deleted = 0
LEFt JOIN Offendertrackeractivation ota ON ota.trackerid = d.deviceid AND ota.deactivatedate is NULL
LEFT JOIN Offender o ON o.Offenderid = ota.Offenderid
LEFt JOIN Agency ag ON ag.agencyid = t.agencyid
LEFt JOIN State st On st.Stateid = ag.Stateid
LEFt JOIN Offender_Officer oo ON oo.Offenderid = ota.Offenderid
LEFt JOIN Officer ofi ON ofi.Officerid = oo.Officerid
JOIN Gateway.dbo.DeviceProperties dp3 ON d.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'
LEFT JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC+nop.MNC = LEFT(dp3.Propertyvalue,6) OR nop.MCC+nop.MNC = LEFT(dp3.Propertyvalue,5)
JOIN Gateway.dbo.DeviceProperties dp4 ON d.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8204'
WHERE LEFT(dp3.Propertyvalue,6) = @Carrierid
ORDEr BY 'Deviceserial'

GO
GRANT EXECUTE ON [DeviceCarrierDetail] TO [db_dml]
GO

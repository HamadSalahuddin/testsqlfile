/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:21:39 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: VIEW
*/
CREATE VIEW [dbo].[DevicePropertiesView]
AS
SELECT     dbo.DeviceSerialNumber.DeviceID, dbo.DeviceHardwareVersion.PropertyValue AS HardwareVersion, dbo.DeviceIMSINumber.PropertyValue AS IMSI, 
                      dbo.DeviceSerialNumber.PropertyValue AS SerialNo, dbo.DeviceManufacturer.PropertyValue AS Manufacturer
FROM         dbo.DeviceHardwareVersion INNER JOIN
                      dbo.DeviceSerialNumber ON dbo.DeviceHardwareVersion.DeviceID = dbo.DeviceSerialNumber.DeviceID INNER JOIN
                      dbo.DeviceIMSINumber ON dbo.DeviceSerialNumber.DeviceID = dbo.DeviceIMSINumber.DeviceID INNER JOIN
                      dbo.DeviceManufacturer ON dbo.DeviceIMSINumber.DeviceID = dbo.DeviceManufacturer.DeviceID

GO

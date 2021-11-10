USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_DeviceHardware]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_DeviceHardware]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_DeviceHardware.sql
 * Created On: 08/15/2011
 * Created By: R.Cole
 * Task #:     2560
 * Purpose:    Populate the Device Hardware Report 
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_DeviceHardware]
AS

DECLARE @GatewayName VARCHAR(1024),
        @RunDate VARCHAR(10)
SET @GatewayName = (SELECT PropertyValue FROM Gateway.dbo.GatewayProperties WHERE PropertyID = '2000')
SET @RunDate = CONVERT(CHAR(10), GETDATE(), 110)
--SET @RunDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)  -- This is faster than convert since it's math vs a char by char operation

SELECT UniqueID,
	     Devices.DeviceID,
	     Devices.CreateTime,
	     dp2.PropertyValue AS 'SerialNumber',
	     dp3.PropertyValue AS 'FirmwareVersion',
	     dp4.propertyvalue AS 'HardwareNumber',
	     dp.PropertyValue AS 'MajorModelNumber',
	     @GatewayName AS 'GatewayName',
	     @RunDate AS 'Date'     
FROM Gateway.dbo.Devices Devices
	INNER JOIN TrackerPal.dbo.OffenderTrackerActivation ota ON Devices.DeviceID = ota.TrackerID
	INNER JOIN Gateway.dbo.DeviceProperties dp ON Devices.DeviceID = dp.DeviceID AND dp.PropertyID = '801a'     --'Major Model Number'
  INNER JOIN Gateway.dbo.DeviceProperties dp2 ON Devices.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8012'  -- 'DeviceName'
  INNER JOIN Gateway.dbo.DeviceProperties dp3 ON Devices.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8201'  -- 'FirmwareVersion'
  INNER JOIN Gateway.dbo.DeviceProperties dp4 ON Devices.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8010'  -- 'HardwareNumber'
WHERE ota.DeactivateDate IS NULL
ORDER BY dp.PropertyValue DESC
GO

GRANT EXECUTE ON [dbo].[spTPal_Rpt_DeviceHardware] TO db_dml;
GO
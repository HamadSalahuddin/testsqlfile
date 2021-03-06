USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_GetDeviceStatus]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_GetDeviceStatus]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ********************************************************
 * FileName:   spTPal_Evt_GetDeviceStatus.sql
 * Created On: 16-Dec-2010
 * Created By: SajidAbbasi
 * Task #:
 * Purpose:    Retreive Device Status for a given event Task #1702
 *
 * Modified By: R.Cole 12/16/2010 - Revised for performance
 *              R.Cole 12/17/2010 - Removed some unused code.
 * ****************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Evt_GetDeviceStatus] (
	@EventTime BIGINT,
	@DeviceID  INT,
	@EventID   INT
)
AS

/* *** Declare Var's *** */
DECLARE @DeviceType INT,
        @IntBatteryFullVoltage INT,
        @IntBatteryEmptyVoltage INT

/* *******************************************************
 * Set Battery Full/Empty Values based on TrackerVersion 
 ********************************************************* */

/* *** Get the Device Type *** */
SET @DeviceType = ISNULL((SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '8017'),0)
 
/* ** TP1 ** */
IF (@DeviceType <= 1)
  BEGIN    
    SET @IntBatteryFullVoltage = 4200
    SET @IntBatteryEmptyVoltage = (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '8051')
  END

/* ****** TP2 Parallel ******** */   
IF (@DeviceType = 2)
  BEGIN
    SET @IntBatteryFullVoltage = 4200
    SET @IntBatteryEmptyVoltage = (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '8048')
  END

/* ******* TP2 Serial ******** */
IF (@DeviceType = 3)
  BEGIN
    SET @IntBatteryFullVoltage = 7900
    SET @IntBatteryEmptyVoltage = (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '804C')
  END

/* **** Get DeviceStatus for the event **** */
BEGIN
  SELECT gwEvents.Status,  
	       gwEvents.InternalBatteryVoltage,
         @IntBatteryFullVoltage AS IntBatteryFullVoltage,
         @IntBatteryEmptyVoltage AS IntBatteryEmptyVoltage
	FROM Gateway.dbo.Events gwEvents
	  LEFT JOIN Gateway.dbo.Devices gwDevices ON gwEvents.DeviceID = gwDevices.DeviceID
	WHERE gwEvents.DeviceID = @DeviceID
	  AND gwEvents.EventID = @EventID
	  AND gwEvents.EventTime = @EventTime
END	  

GRANT EXECUTE ON [dbo].[spTPal_Evt_GetDeviceStatus] TO db_dml;
GO
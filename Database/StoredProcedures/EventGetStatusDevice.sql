USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EventGetStatusDevice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EventGetStatusDevice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ********************************************************
 * FileName:   EventGetStatusDevice.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:
 * Purpose:    Retreive Device Status for a given event
 *
 * Modified By:  R.Cole - 11/13/2009
 *               Revised Query to improve speed and
 *               readability.
 *               R.Cole - 12/23/2009 - Task #538
 *               R.Cole - 01/25/2010 - Task #614 / #628
 ******************************************************* */

CREATE PROCEDURE [dbo].[EventGetStatusDevice] (
	@EventTime BIGINT,
	@DeviceID  INT,
	@EventID   INT
)
AS

/* *** Declare Var's *** */
DECLARE @EventDateTime DATETIME,
        @DeviceType INT,
        @ExtBatteryFullVoltage INT,
        @ExtBatteryEmptyVoltage INT,
        @IntBatteryFullVoltage INT,
        @IntBatteryEmptyVoltage INT

/* *** Convert the EventTime to something useable *** */
SET @EventDateTIME = dbo.ConvertLongToDate(@EventTime)

/* *******************************************************
 * Set Battery Full/Empty Values based on TrackerVersion 
 ********************************************************* */

/* *** Get the Device Type *** */
SET @DeviceType = ISNULL((SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '8017'),0)
 
/* ** TP1 ** */
IF (@DeviceType <= 1)
  BEGIN
    SET @ExtBatteryFullVoltage = 4200
    SET @ExtBatteryEmptyVoltage = (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '8041')
    SET @IntBatteryFullVoltage = 4200
    SET @IntBatteryEmptyVoltage = (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '8051')
  END

/* ****** TP2 Parallel ******** */   
IF (@DeviceType = 2)
  BEGIN
    SET @ExtBatteryFullVoltage = -1   -- There is no ExternalBattery on TP2's
    SET @ExtBatteryEmptyVoltage = -1
    SET @IntBatteryFullVoltage = 4200
    SET @IntBatteryEmptyVoltage = (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '8048')
  END

/* ******* TP2 Serial ******** */
IF (@DeviceType = 3)
  BEGIN
    SET @ExtBatteryFullVoltage = -1   -- There is no ExternalBattery on TP2's
    SET @ExtBatteryEmptyVoltage = -1
    SET @IntBatteryFullVoltage = 7900
    SET @IntBatteryEmptyVoltage = (SELECT Gateway.dbo.HexToSmallInt(PropertyValue) FROM Gateway.dbo.DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = '804C')
  END

/* *** See if Event is in Bucket1 *** */
IF(SELECT COUNT(EventPrimaryID) FROM rprtEventsBucket1 WHERE DeviceID = @DeviceID AND EventID = @EventID AND EventDateTime = @EventDateTime) > 0
  BEGIN
    SELECT Bucket1.OffenderName,  
		       Bucket1.EventNAme,     
		       Bucket1.DeviceID,   
		       Bucket1.EventTime,   
		       gwDevices.name AS devicename,  
		       Bucket1.trackerNumber AS devicenumber,  
		       Bucket1.GpsValidSatellites,  
		       Bucket1.latitude,  
		       Bucket1.longitude,  
		       gwEvents.Status,  
		       Bucket1.GpsValid,  
		       Bucket1.address,
		       gwEvents.ExternalBatteryVoltage,
		       gwEvents.InternalBatteryVoltage,
           @ExtBatteryFullVoltage AS ExtBatteryFullVoltage,
           @ExtBatteryEmptyVoltage AS ExtBatteryEmptyVoltage,
           @IntBatteryFullVoltage AS IntBatteryFullVoltage,
           @IntBatteryEmptyVoltage AS IntBatteryEmptyVoltage,
		       gwEvents.SignalStrength,
		       gwEvents.GpsSatellites,
		       gwEvents.Speed,
		       gwEvents.Heading
		FROM rprtEventsBucket1 Bucket1   
		  LEFT JOIN Gateway.dbo.Events gwEvents ON Bucket1.DeviceID = gwEvents.DeviceID
		        AND Bucket1.EventID = gwEvents.EventID 
		        AND Bucket1.EventTime = gwEvents.EventTime   
		  LEFT JOIN Gateway.dbo.Devices gwDevices ON Bucket1.DeviceID = gwDevices.DeviceID 
		WHERE Bucket1.DeviceID = @DeviceID
		  AND Bucket1.EventID = @EventID 
		  AND Bucket1.EventDateTime = @EventDateTime  
		ORDER BY Bucket1.EventTime DESC 
	END
ELSE
    /* *** Event is in Bucket2 *** */
	BEGIN
		SELECT Bucket2.OffenderName,  
		       Bucket2.EventNAme,     
		       Bucket2.DeviceID,   
		       Bucket2.EventTime,   
		       gwDevices.name AS devicename,  
		       Bucket2.trackerNumber AS devicenumber,  
		       Bucket2.GpsValidSatellites,  
		       Bucket2.latitude,  
		       Bucket2.longitude,  
		       gwEvents.Status,  
		       Bucket2.GpsValid,  
		       Bucket2.address,
		       gwEvents.ExternalBatteryVoltage,
		       gwEvents.InternalBatteryVoltage,
           @ExtBatteryFullVoltage AS ExtBatteryFullVoltage,
           @ExtBatteryEmptyVoltage AS ExtBatteryEmptyVoltage,
           @IntBatteryFullVoltage AS IntBatteryFullVoltage,
           @IntBatteryEmptyVoltage AS IntBatteryEmptyVoltage,
		       gwEvents.SignalStrength,
		       gwEvents.GpsSatellites,
		       gwEvents.Speed,
		       gwEvents.Heading
		FROM rprtEventsBucket2 Bucket2   
		  LEFT JOIN Gateway.dbo.Events gwEvents ON Bucket2.DeviceID = gwEvents.DeviceID 
		        AND Bucket2.EventID = gwEvents.EventID 
		        AND Bucket2.EventTime = gwEvents.EventTime   
		  LEFT JOIN Gateway.dbo.Devices gwDevices ON Bucket2.DeviceID = gwDevices.DeviceID   
		WHERE Bucket2.DeviceID = @DeviceID 
		  AND Bucket2.EventID = @EventID 
		  AND Bucket2.EventDateTime = @EventDateTime    
	END
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[EventGetStatusDevice] TO db_dml;
GO
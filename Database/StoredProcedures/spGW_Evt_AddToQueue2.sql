USE [Gateway]															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spGW_Evt_AddToQueue2]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGW_Evt_AddToQueue2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spGW_Evt_AddToQueue2.sql
 * Created On: 09-Sep-2011         
 * Created By: SABBASI  
 * Task #:     Redmine #      
 * Purpose:    Save Event to TrackerPalQueue2. Also delete the event 
 *             from TrackerPalQueue1 if it is successfully saved.               
 *
 * Modified By: R.Cole - 9/9/2011: Added DROP IF EXISTS and
 *                GRANT stmts for SVN version. 
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spGW_Evt_AddToQueue2] (
	@EventTime BIGINT,
	@DeviceID INT,
	@EventID INT,
	@EventParameter	INT,
	@GpsValid	BIT,
	@GpsValidSatellites	BIT,
	@ReceivedTime	DATETIME,
	@TransmittedTime DATETIME,
	@Latitude	FLOAT,
	@Longitude FLOAT,
	@EventName VARCHAR(64),
	@AlarmType INT,
	@Enabled BIT,
	@GpsSatellites	TINYINT,
	@Speed	TINYINT,
	@Heading TINYINT,
	@Hdop	SMALLINT,
	@InternalBatteryVoltage	SMALLINT,
	@ExternalBatteryVoltage	SMALLINT,
	@SignalStrength	TINYINT,
	@Status	INT,
	@BeaconSerialNumber	CHAR,
	@Address NVARCHAR(2000),
	@RadiusOfConfidence	INT
)
AS
BEGIN
	SET NOCOUNT ON;

  INSERT INTO TrackerPalQueue2(
    EventTime, 
    DeviceID, 
    EventID, 
    EventParameter, 
    GpsValid, 
		GpsValidSatellites, 
		ReceivedTime, 
		TransmittedTime, 
		Latitude, 
		Longitude,
		EventName, 
		AlarmType, 
		Enabled, 
		GpsSatellites, 
		Speed, 
		Heading, 
		Hdop, 
		InternalBatteryVoltage, 
		SignalStrength, 
		ExternalBatteryVoltage, 
		Status, 
		BeaconSerialNumber, 
		Address, 
		RadiusOfConfidence
	)
	VALUES(
	  @EventTime, 
	  @DeviceID, 
	  @EventID, 
	  @EventParameter, 
	  @GpsValid,
		@GpsValidSatellites, 
		@ReceivedTime, 
		@TransmittedTime, 
		@Latitude, 
		@Longitude,
		@EventName, 
		@AlarmType, 
		@Enabled, 
		@GpsSatellites, 
		@Speed,
		@Heading, 
		@Hdop, 
		@InternalBatteryVoltage, 
		@SignalStrength, 
		@ExternalBatteryVoltage,
		@Status, 
		@BeaconSerialNumber, 
		@Address, 
		@RadiusOfConfidence
	)
  
  -- // Delete record from TrackerPalQueue1 if the insert is successful // --
	IF @@ERROR = 0
		BEGIN
		  EXEC DeleteEventFromQueue1 @EventTime, @DeviceID, @EventID
		END
END
GO

GRANT EXECUTE ON [dbo].[spGW_Evt_AddToQueue2] TO db_dml;
GO
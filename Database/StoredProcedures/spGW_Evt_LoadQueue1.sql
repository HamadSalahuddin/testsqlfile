USE [Gateway]															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spGW_Evt_LoadQueue1]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGW_Evt_LoadQueue1]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spGW_Evt_LoadQueue1.sql
 * Created On: 9/9/2011
 * Created By: Sajid
 * Task #:     Redmine #      
 * Purpose:    Loads events from Queue1               
 *
 * Modified By: R.Cole - 9/9/2011: Added DROP IF EXISTS and
 *                GRANT stmts.  Removed SELECT *
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spGW_Evt_LoadQueue1] (
	@RecordLimit INT
)
AS
BEGIN
	SET ROWCOUNT @RecordLimit

	SELECT EventTime,
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
	       ExternalBatteryVoltage,
	       SignalStrength,
	       Status,
	       BeaconSerialNumber
	FROM TrackerPalQueue1 WITH (NOLOCK)
	ORDER BY EventTime

	SET ROWCOUNT 0
END
GO

GRANT EXECUTE ON [dbo].[spGW_Evt_LoadQueue1] TO db_dml;
GO
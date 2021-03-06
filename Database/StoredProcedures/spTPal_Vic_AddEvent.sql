USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_AddEvent]    Script Date: 6/18/2021 4:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* **********************************************************
 * FileName:   spTPal_Vic_AddEvent.sql
 * Created On: 02/20/2013
 * Created By: R.Cole
 * Task #:     3886
 * Purpose:    Add a new victim event               
 *
 * Modified By: SABBASI - 03/13/2013 Removed  Update LastEventTime for VictimDevice_Tracker
 * Ass same field is already present in VictimDevice table.
 *            : HSalahuddin- 01/04/2014 changed the table name from VictimDevices to VictimDevice
 *			SABBASI - 06/10/2014 ; Support #6395; Added GPSValid and GPSValidSatellite in the argument list..
			DRIDING 6/24/15	- Add @RawMessage parameter. populate ProcessedTime and RawMessage columns
			H.SAlahuddin 09/30/2016 Task#10745 added transmittedTime field
			H.Salahuddin 11/15/2016 Task# 10932 Added SequenceNumber field.
			H.Salahuddin 06/18/2021 TPL-529 Added VictimID and OffenderID in VictimEvents table.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Vic_AddEvent] (
  @VictimDeviceID INT,
  @DeviceIMEI NVARCHAR(32),
  @EventDisplayTime DATETIME,
  @EventTypeID INT,  
  @Latitude FLOAT,
  @Longitude FLOAT,
  @GPSValid BIT,
  @GPSValidSatellites BIT, 
  @RawMessage varchar(500) = NULL,
  @TransmittedTime DATETIME,
  @SequenceNumber	INT = NULL,
  @BatteryPercentage INT =NULL,
  @OffenderID INT,
  @VictimID INT
) 
AS
BEGIN
  BEGIN TRANSACTION	   
    -- // Main Query // --
    INSERT INTO VictimEvents (      
      [VictimDeviceID],
      [DeviceIMEI],           -- Might be removed  
      [EventDisplayTime],     -- Normal Datetime in UTC
      [EventTypeID],  
      [Latitude],
      [Longitude],
	  [GPSValid],
	  [GPSValidSatellites],
	  ProcessedDate,
	  RawMessage,
	  TransmittedTime,
	  SequenceNumber,
	  BatteryPercentage,
	  OffenderID,
	  VictimID
    )
    VALUES (
      @VictimDeviceID,
      @DeviceIMEI,
      @EventDisplayTime,
      @EventTypeID,
      @Latitude,
      @Longitude,
	  @GPSValid,
      @GPSValidSatellites,
	  CURRENT_TIMESTAMP, 
	  @RawMessage,
	  @TransmittedTime,
	  @SequenceNumber,
	  @BatteryPercentage,
	  @OffenderID,
	  @VictimID
    )
    IF (@@ERROR <> 0) GOTO ErrorHandler

    -- // Update LastEventTime for VictimDevice // --
    UPDATE VictimDevice
      SET LastEventTime = @EventDisplayTime
      WHERE VictimDeviceID = @VictimDeviceID
    IF (@@ERROR <> 0) GOTO ErrorHandler

    -- // Update LastEventTime for VictimDevice_Tracker // --
  /*  UPDATE VictimDevice_Tracker
      SET LastEventTime = @EventDisplayTime
      WHERE VictimDeviceID = @VictimDeviceID
    IF (@@ERROR <> 0) GOTO ErrorHandler*/

	COMMIT TRANSACTION
	RETURN 0

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN 1	
END



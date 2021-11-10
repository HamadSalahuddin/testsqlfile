USE [Gateway]
GO
/****** Object:  StoredProcedure [dbo].[AddShadowEvent]    Script Date: 04/13/2017 12:26:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   AddShadowEvent.sql
 * Created On: Unknown         
 * Created By: Puracom  
 * Task #:     N/A
 * Purpose:    Add and event record to the Events table               
 *
 * Modified By: D. Riding  1/13/15
				Proc based on AddEvent. Created new version for Shadow with not-applicable code removed. 
				D. Riding 1/4/16	Reset TimeoutCount to 0 for Device when the event is not a non-comm event (256 or 258).
				H. Salahuddin 04/13/2017 Task # 11003 Added StreetAddress field 
 * updating status word. 
 * ******************************************************** */
ALTER PROCEDURE [dbo].[AddShadowEvent] (
	@DeviceID INT,
	@EventTime BIGINT,
	@EventID INT,
	@EventParameter INT,
	@GpsValid BIT,
	@GpsValidSatellites BIT,
	@GpsFixType TINYINT,
	@GpsSatellites TINYINT,
	@TimeValid BIT,
	@Latitude FLOAT,
	@Longitude FLOAT,
	@Speed TINYINT,
	@Heading TINYINT,
	@Hdop SMALLINT,
	@InternalBatteryVoltage SMALLINT,
	@SignalStrength TINYINT,
	@Status INT,
	@TransmittedTime DATETIME,
	@ReceivedTime DATETIME,
	@Transport TINYINT,
	@TrackerSegment BIT,
	@BeaconSerialNumber CHAR(13),
	@BeaconFirmwareVersion TINYINT,
	@BeaconMovedCount TINYINT,
	@BeaconBatteryVoltage TINYINT,
	@BeaconSignalStrength TINYINT,
	@BeaconTemperature TINYINT,
	@BeaconReceivedTime DATETIME,
	@BeaconTransmittedTime DATETIME,
	@BeaconTransportType TINYINT,
	@BeaconSegment BIT,
	@EventTables SMALLINT,			/* 0x08: TrackerAPL Queue. */ 
  @MaxTrackerPalRecords INT,
	@CommResumed INT OUTPUT,
	@StreetAddress VARCHAR(100) = ''
)
AS
BEGIN
	DECLARE	@Enabled BIT,
	        @CopyEvent BIT,
	        @FoundTrackerSegment BIT,
	        @FoundBeaconSegment BIT,
	        @FoundAddress BIT	

  SET @CopyEvent = 0


  SELECT @FoundTrackerSegment = TrackerSegment, 
         @FoundBeaconSegment = BeaconSegment
  FROM Events WITH (NOLOCK)
  WHERE DeviceID = @DeviceID 
    AND EventTime = @EventTime 
    AND EventID = @EventID
   

  IF @@ROWCOUNT = 0 
    BEGIN
      /* Add an entry to the Events database. */
      SET @CopyEvent = 1
		  BEGIN TRANSACTION
			   INSERT INTO Events WITH (ROWLOCK) (DeviceID, EventTime, EventID, EventParameter, GpsValid, GpsValidSatellites, GpsFixType, GpsSatellites, TimeValid, Latitude, Longitude, Speed, Heading,  Hdop,  InternalBatteryVoltage, SignalStrength, [Status], TransmittedTime, ReceivedTime, Transport, TrackerSegment, BeaconSerialNumber, BeaconFirmwareVersion, BeaconMovedCount, BeaconBatteryVoltage, BeaconSignalStrength, BeaconTemperature, BeaconReceivedTime, BeaconTransmittedTime, BeaconTransportType, BeaconSegment,StreetAddress )
			   VALUES (@DeviceID, @EventTime, @EventID, @EventParameter, @GpsValid, @GpsValidSatellites, @GpsFixType, @GpsSatellites, @TimeValid, @Latitude, @Longitude, @Speed, @Heading, @Hdop, @InternalBatteryVoltage, @SignalStrength, @Status, @TransmittedTime, @ReceivedTime, @Transport, @TrackerSegment, @BeaconSerialNumber, @BeaconFirmwareVersion, @BeaconMovedCount, @BeaconBatteryVoltage, @BeaconSignalStrength, @BeaconTemperature, @BeaconReceivedTime, @BeaconTransmittedTime, @BeaconTransportType, @BeaconSegment,@StreetAddress)
      
        IF (@@ERROR <> 0) 
          GOTO ErrorHandler
		  COMMIT TRANSACTION
    END 
  ELSE
           /* Determine the message is a duplicate. If it is, then add it the DuplicateEvents table. Otherwise, update
           the appropriate fields in the associated record in the Events table.											*/  
        BEGIN  
          IF (@FoundTrackerSegment = 1 and @TrackerSegment = 1 ) OR ( @FoundBeaconSegment = 1 AND @BeaconSegment = 1) 
            BEGIN
				      BEGIN TRANSACTION
	           INSERT INTO DuplicateEvents WITH (ROWLOCK) (DeviceID, EventTime, EventID, EventParameter, GpsValid, GpsValidSatellites, GpsFixType, GpsSatellites, TimeValid, Latitude, Longitude, Speed, Heading, Hdop, InternalBatteryVoltage, SignalStrength, Status, TransmittedTime, ReceivedTime, Transport, TrackerSegment, BeaconSerialNumber, BeaconFirmwareVersion, BeaconMovedCount, BeaconBatteryVoltage, BeaconSignalStrength, BeaconTemperature, BeaconReceivedTime, BeaconTransmittedTime, BeaconTransportType, BeaconSegment,StreetAddress )
		       VALUES (@DeviceID, @EventTime, @EventID, @EventParameter, @GpsValid, @GpsValidSatellites, @GpsFixType, @GpsSatellites, @TimeValid, @Latitude, @Longitude, @Speed, @Heading,  @Hdop, @InternalBatteryVoltage,  @SignalStrength, @Status, @TransmittedTime, @ReceivedTime, @Transport, @TrackerSegment, @BeaconSerialNumber, @BeaconFirmwareVersion, @BeaconMovedCount, @BeaconBatteryVoltage, @BeaconSignalStrength, @BeaconTemperature, @BeaconReceivedTime, @BeaconTransmittedTime, @BeaconTransportType, @BeaconSegment, @StreetAddress)
				        
                IF (@@ERROR <> 0) GOTO ErrorHandler  
				      COMMIT TRANSACTION
            END
          ELSE
            BEGIN
	            IF @TrackerSegment = 1 
	              BEGIN
		              SET @CopyEvent = 1
						      BEGIN TRANSACTION
		                UPDATE Events WITH (ROWLOCK) SET GpsValid = @GpsValid, GpsValidSatellites = @GpsValidSatellites, GpsFixType = @GpsFixType, GpsSatellites = @GpsSatellites, TimeValid = @TimeValid, Latitude = @Latitude, Longitude = @Longitude, Speed = @Speed, Heading = @Heading, Hdop = @Hdop, InternalBatteryVoltage = @InternalBatteryVoltage, SignalStrength = @SignalStrength, Status = @Status, TransmittedTime = @TransmittedTime, ReceivedTime = @ReceivedTime, Transport = @Transport, TrackerSegment = @TrackerSegment	,StreetAddress =@StreetAddress
			                WHERE DeviceID = @DeviceID AND EventTime = @EventTime AND EventID = @EventID AND EventParameter = @EventParameter

		                IF (@@ERROR <> 0) GOTO ErrorHandler
						      COMMIT TRANSACTION
	              END

	            IF @BeaconSegment = 1
	              BEGIN
	                SET @CopyEvent = 1
						      BEGIN TRANSACTION
		                UPDATE Events set BeaconSerialNumber = @BeaconSerialNumber, BeaconFirmwareVersion = @BeaconFirmwareVersion, BeaconMovedCount = @BeaconMovedCount, BeaconBatteryVoltage = @BeaconBatteryVoltage, BeaconSignalStrength = @BeaconSignalStrength, BeaconTemperature = @BeaconTemperature, BeaconReceivedTime = @BeaconReceivedTime, BeaconTransmittedTime = @BeaconTransmittedTime, BeaconTransportType = @BeaconTransportType, BeaconSegment = @BeaconSegment 
			                WHERE DeviceID = @DeviceID AND EventTime = @EventTime AND EventID = @EventID AND EventParameter = @EventParameter

		                IF (@@ERROR <> 0) GOTO ErrorHandler
						      COMMIT TRANSACTION
	              END
            END
        END
    
	  
 -- /* Add to the WebApi databases only if the event type is enabled. */
	IF @CopyEvent = 1 AND @EventTables & 8 = 8
	  BEGIN
      SET @Enabled = (SELECT Enabled FROM EventTypes WITH (NOLOCK) WHERE EventID = @EventID)
		  IF (@@ERROR <> 0) GOTO ErrorHandler

      IF @Enabled = 1
        BEGIN
		    /* Add an entry to the TrackerPAL database. */
		     EXEC InsertInTrackerPalQueue @DeviceID, @EventTime, @EventID, @EventParameter, @MaxTrackerPalRecords
		     IF (@@ERROR <> 0) GOTO ErrorHandler
			    
		END 
	  END
	  
	   DECLARE @LastReceivedTime BIGINT
  SET @LastReceivedTime= dbo.ConvertDateToLong(@ReceivedTime)

  SELECT @CommResumed = CASE WHEN @EventID NOT IN (256, 257, 258) AND TimeoutCount > 0 THEN 1 ELSE 0 END FROM Devices WHERE DeviceID = @DeviceID

  UPDATE Devices SET LastEventTime = CASE WHEN LastEventTime < @EventTime THEN @EventTime ELSE LastEventTime END,
					LastReceivedTime = CASE WHEN LastReceivedTime < @LastReceivedTime THEN @LastReceivedTime ELSE LastReceivedTime END,
					TimeoutCount = CASE WHEN @EventID NOT IN (256, 258) THEN 0 ELSE TimeoutCount END, --DRiding 1/3/16 to set the TimeoutCount to 0, shouldn't be a non-comm event and shouldn't be an old event.
					LastValidTime = CASE WHEN LastValidTime < @EventTime AND @GpsValid = 1 AND @GpsValidSatellites = 1 THEN @EventTime ELSE LastValidTime END
					 WHERE DeviceID = @DeviceID 
  IF (@@ERROR <> 0) GOTO ErrorHandler

	
  RETURN 0

 
  ErrorHandler:
	  ROLLBACK TRANSACTION
	  RETURN 1	
END

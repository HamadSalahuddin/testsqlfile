USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[mAlarmInsert]    Script Date: 10/18/2011 10:52:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[mAlarmInsert]

	@AlarmID bigint output,
	@OffenderID	INT,
	@TrackerID int,
	@EventTypeID int,
	@EventTime  bigint,
  @ReceivedTime  datetime,
  @EventDisplayTime  datetime,
  @AlarmTypeID  int,
  @Latitude  float,
  @Longitude  float,
  @EventParameter  bigint,
  -- event specific variables
	@TrackerNumber varchar(32)=null,
	@EventName varchar(50) = null,
	@OfficerID bigint = null,
	@AgencyID int = null,
	@SO bit = null,
	@OPR bit = null,
	@GeoRuleName nvarchar(50) = null,
	@GpsValid bit = null,
	@GpsValidSatellites int = null,
	@EventTypeGroupID int =null,
	@OffenderName nvarchar(100),
	@BeaconSerialNumber varchar(100) = null,
  @EventAddress VARCHAR(100) = NULL,
	@RadiusOfConfidence INT = NULL 

AS

IF NOT EXISTS (SELECT TOP 1 AlarmID 
			FROM Alarm 
			WHERE TrackerID = @TrackerID AND EventTime = @EventTime AND EventTypeID = @EventTypeID)
BEGIN
Declare @Address varchar(100)
	
	if @EventTypeID in (176,177,178,179,180,181,182,184,185,192,193,194,195) 
		BEGIN
			exec mBeaconGetAddressBySerialNumber @BeaconSerialNumber, @OffenderId, @Address OUTPUT, @Latitude OUTPUT, @Longitude OUTPUT
		END

INSERT INTO [dbo].[Alarm]
           ([OffenderID]
           ,[TrackerID]
           ,[EventTypeID]
           ,[EventTime]
           ,[ReceivedTime]
           ,[EventDisplayTime]
           ,[AlarmTypeID]
           ,[Latitude]
           ,[Longitude]
           ,[EventParameter]
		       ,[Address]
           )
     VALUES
           (@OffenderID
           ,@TrackerID
           ,@EventTypeID
           ,@EventTime
           ,@ReceivedTime
           ,@EventDisplayTime
           ,@AlarmTypeID
           ,@Latitude
           ,@Longitude
           ,@EventParameter
		       ,@Address
)
END           
SET @AlarmID = (
			SELECT TOP 1 AlarmID 
			FROM Alarm 
			WHERE TrackerID = @TrackerID AND EventTime = @EventTime AND EventTypeID = @EventTypeID
		)

--insert event 
DECLARE	@return_value int,
		@EventPrimaryID bigint

EXEC @return_value = [dbo].[mEventInsertBucket1]
		@EventPrimaryID = @EventPrimaryID OUTPUT,
		@EventID = @EventTypeID,
		@EventTypeGroupID = @EventTypeGroupID,
		@AlarmTypeID = @AlarmTypeID,
		@AlarmID = @AlarmID,
		@DeviceID = @TrackerID,
		@TrackerNumber =@TrackerNumber,
		@EventName = @EventName,
		@EventTime = @EventTime,
		@EventDateTime = @EventDisplayTime,
		@EventParameter = @EventParameter,
		@AgencyID = @AgencyID,
		@OffenderID = @OffenderID,
		@OfficerID = @OfficerID,
		@ReceivedTime = @ReceivedTime,
		@Latitude = @Latitude,
		@Longitude = @Longitude,
		@SO = @SO,
		@OPR = @OPR,
		@NoteCount = NULL,
		@GeoRuleName = @GeoRuleName,
		@AlarmAssignmentStatusID = NULL,
		@AcceptedBy = NULL,
		@ActivateDate = NULL,
		@DeActivateDate = NULL,
		@GpsValid = @GpsValid,
		@GpsValidSatellites = @GpsValidSatellites,
		@AcceptedDate = NULL,
		@AlarmAssignmentStatus = NULL,
		@EventQueueID = NULL,
		@OffenderName = @OffenderName,
		@BeaconSerialNumber = @BeaconSerialNumber,
    @Address = @EventAddress ,
		@RadiusOfConfidence =  @RadiusOfConfidence    

SELECT	@EventPrimaryID as N'@EventPrimaryID'





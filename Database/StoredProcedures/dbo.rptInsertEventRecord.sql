/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [rptInsertEventRecord]
@EventPrimaryID	bigint OUTPUT,
@EventID bigint,
@EventTypeGroupID bigint = null,
@AlarmTypeID int = null,
@AlarmID bigint = null,
@DeviceID bigint,
@TrackerNumber varchar(32)= null,
@EventName varchar(50) = null,
@EventTime	bigint,
@EventDateTime DateTime = null,
@EventParameter bigint = null,
@AgencyID int = null,
@OffenderID bigint = null,
@OfficerID bigint = null,
@ReceivedTime DateTime = null,
@Latitude float = null,
@Longitude float = null,
@SO bit = null,
@OPR bit = null,
@NoteCount int = null,
@GeoRuleName nvarchar(50) = null,
@AlarmAssignmentStatusID int = null,
@AcceptedBy int = null,
@ActivateDate DateTime = null,
@DeActivateDate DateTIme = null,
@GpsValid bit = null,
@GpsValidSatellites int = null,
@AcceptedDate DateTime = null,
@AlarmAssignmentStatus nvarchar(50) = null,
@EventQueueID int = null,
@OffenderName nvarchar(100),
@OffenderDeleted bit



AS
DECLARE @bucket1Time DateTime, @WindowTime datetime


SELECT @bucket1Time = DateADD(minute,-90,getdate())
SET @WindowTime = DateADD(minute,-5,@bucket1Time)

if (@EventDateTime>@bucket1Time)
BEGIN
	INSERT rprtEventsBucket1 (	
			EventID,
			DeviceID,
			EventTime,
			EventDateTime,
			TrackerNumber,
			EventName,
			EventParameter,
			ReceivedTime,
			OfficerID,
			OffenderID,
			AgencyID,
			Latitude,
			Longitude,
			OPR,
			SO,
			NoteCount,
			AlarmType,
			AlarmID,
			GeoRule,
			AlarmAssignmentStatusID,
			AlarmAssignmentStatusName,
			AcceptedBy,
			ActivateDate,
			DeActivateDate,
			GpsValid,
			GpsValidSatellites,
			AcceptedDate,
			EventTypeGroupID,
			EventQueueID,
			OffenderName,
			OffenderDeleted

 )
		VALUES (
			@EventID,
			@DeviceID,
			@EventTime,
			@EventDateTime,
			@TrackerNumber,
			@EventName,
			@EventParameter,
			@ReceivedTime,	
			@OfficerID,	
			@OffenderID,
			@AgencyID,
			@Latitude,
			@Longitude,
			@SO,
			@OPR,
			@NoteCount,
			@AlarmTypeID,
			@AlarmID,
			@GeoRuleName,
			@AlarmAssignmentStatusID,
			@AlarmAssignmentStatus,
			@AcceptedBy,
			@ActivateDate,
			@DeActivateDate,
			@GpsValid,
			@GpsValidSatellites,
			@AcceptedDate,
			@EventTypeGroupID,
			@EventQueueID,
			@OffenderName,
			@OffenderDeleted			 

		)
SET @EventPrimaryID = @@IDENTITY
END
ELSE
BEGIN
	INSERT rprtEventsBucket1 (	
			EventID,
			DeviceID,
			EventTime,
			EventDateTime,
			EventParameter,
			TrackerNumber,
			EventName,
			ReceivedTime,
			OfficerID,
			OffenderID,
			AgencyID,
			Latitude,
			Longitude,
			OPR,
			SO,
			NoteCount,
			AlarmType,
			AlarmID,
			GeoRule,
			AlarmAssignmentStatusID,
			AlarmAssignmentStatusName,
			AcceptedBy,
			ActivateDate,
			DeActivateDate,
			GpsValid,
			GpsValidSatellites,
			AcceptedDate,
			EventTypeGroupID,
			EventQueueID,
			OffenderName,
			OffenderDeleted

 )
		VALUES (
			@EventID,
			@DeviceID,
			@EventTime,
			@EventDateTime,
			@EventParameter,
			@TrackerNumber,
			@EventName,
			@ReceivedTime,	
			@OfficerID,	
			@OffenderID,
			@AgencyID,
			@Latitude,
			@Longitude,
			@SO,
			@OPR,
			@NoteCount,
			@AlarmTypeID,
			@AlarmID,
			@GeoRuleName,
			@AlarmAssignmentStatusID,
			@AlarmAssignmentStatus,
			@AcceptedBy,
			@ActivateDate,
			@DeActivateDate,
			@GpsValid,
			@GpsValidSatellites,
			@AcceptedDate,
			@EventTypeGroupID,
			@EventQueueID,
			@OffenderName,
			@OffenderDeleted		 

		)
SET @EventPrimaryID = @@IDENTITY
END

DECLARE @OldestEventDateTime AS DateTime--, @WaitTime AS DateTime

SELECT @OldestEventDateTime = MIN(EventDateTime) FROM rprtEventsBucket1 WITH (NOLOCK)
--IF @OldestEventDateTime < @WindowTime
--BEGIN
----	SET @WaitTime = DateADD(minute,-90,getdate())
--
----	SET IDENTITY_INSERT rprtEventsBucket2 ON
--	INSERT rprtEventsBucket2 
--		( EventID,DeviceID,EventTime,EventDateTime,EventParameter,TrackerNumber,EventName,ReceivedTime,OfficerID,
--		OffenderID,AgencyID,Latitude,Longitude,OPR,SO,NoteCount,AlarmType,AlarmID,GeoRule,AlarmAssignmentStatusID,
--		AlarmAssignmentStatusName,AcceptedBy,ActivateDate,DeActivateDate,GpsValid,GpsValidSatellites,AcceptedDate,
--		EventTypeGroupID,EventQueueID,OffenderName,OffenderDeleted,Address )
--	SELECT EventID,DeviceID,EventTime,EventDateTime,EventParameter,TrackerNumber,EventName,ReceivedTime,OfficerID,
--		OffenderID,AgencyID,Latitude,Longitude,OPR,SO,NoteCount,AlarmType,AlarmID,GeoRule,AlarmAssignmentStatusID,
--		AlarmAssignmentStatusName,AcceptedBy,ActivateDate,DeActivateDate,GpsValid,GpsValidSatellites,AcceptedDate,
--		EventTypeGroupID,EventQueueID,OffenderName,OffenderDeleted,Address
--	FROM rprtEventsBucket1 
--	WHERE EventDateTime < @bucket1Time
----	SET IDENTITY_INSERT rprtEventsBucket2 OFF
--
--	DELETE rprtEventsBucket1 WHERE EventDateTime < @bucket1Time
--END

--	SELECT MIN(EventDateTime) FROM rprtEventsBucket1








GO
GRANT EXECUTE ON [rptInsertEventRecord] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [rptInsertEventRecord] TO [db_object_def_viewers]
GO

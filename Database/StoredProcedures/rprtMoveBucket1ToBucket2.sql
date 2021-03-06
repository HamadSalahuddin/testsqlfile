USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[rprtMoveBucket1ToBucket2]    Script Date: 10/05/2011 10:46:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[rprtMoveBucket1ToBucket2]
AS
BEGIN
	DECLARE @bucket1MaxDate DATETIME,
	        @movedRecordCount BIGINT,
	        @HighWaterMark DATETIME
	
	-- // Get current Bucket1 cutoff // --
	SELECT @bucket1MaxDate = DateADD(minute,-4320,getdate())
	SELECT @bucket1MaxDate
	
	-- // Get records to process // --
	SELECT TOP 5000 * INTO #rprtMoveBucket1ToBucket2 FROM rprtEventsBucket1 WITH (NOLOCK) WHERE EventDateTime<@bucket1MaxDate	
	SELECT @movedRecordCount = COUNT(*) FROM #rprtMoveBucket1ToBucket2

	-- // Insert into Bucket 2 // --
	INSERT rprtEventsBucket2 ( 
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
		OffenderDeleted,
		Address
	)
	SELECT EventID,
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
		OffenderDeleted,
		Address 
	FROM #rprtMoveBucket1ToBucket2 

	-- // Delete Original Records // --
	DELETE FROM rprtEventsBucket1 WITH (ROWLOCK) WHERE EventPrimaryID in (SELECT EventPrimaryID from #rprtMoveBucket1ToBucket2)
	DROP TABLE #rprtMoveBucket1ToBucket2
	
	-- // Update highwater mark // --
	SET @HighWaterMark = (SELECT MIN(EventDateTime) FROM rprtEventsBucket1 WITH (NOLOCK))
	IF @HighWaterMark IS NOT NULL
	  UPDATE RTM_TableState
	    SET RTM_HighTime = @HighWaterMark
	    WHERE RTM_TableName = 'BucketMover_Bucket1'
	
	-- // Return rows moved // --
	SELECT @movedRecordCount
END










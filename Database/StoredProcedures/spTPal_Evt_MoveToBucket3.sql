USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_MoveToBucket3]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_MoveToBucket3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   [spTPal_Evt_MoveToBucket3].sql
 * Created On: 5/2/2011
 * Created By: R.Cole
 * Task #:     N/A
 * Purpose:    Move events older than 18 months to Bucket3
 *             for archving.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [spTPal_Evt_MoveToBucket3]
AS
BEGIN
  
  -- // Begin Tran // --
  BEGIN TRAN;

  -- // Declare Var's // --
	DECLARE @Bucket2MaxDate DateTime
	DECLARE @MovedRecordCount bigint
	
	-- // Get current Max Date // --
	SELECT @Bucket2MaxDate = DATEADD(MONTH, -18, GETDATE())
	
	-- // Get the records to move // --
	SELECT TOP 10000 *
  INTO #tmpMoveToBucket3 
  FROM rprtEventsBucket2 WITH (NOLOCK) 
  WHERE EventDateTime < @Bucket2MaxDate
  ORDER BY EventDatetime

	-- // Index temp table for speed // --
	CREATE CLUSTERED INDEX #xpktmpMoveToB3 ON #tmpMoveToBucket3(EventPrimaryID)
	
	-- // Set the Moved Record Count // --
	SELECT @MovedRecordCount = COUNT(*) FROM #tmpMoveToBucket3
	
	-- // Insert into Bucket3	// --
	INSERT rprtEventsBucket3 ( 
	  EventPrimaryID, 
	  DeviceID,
	  EventTime,
	  EventDateTime,
	  ReceivedTime,
	  TrackerNumber,
	  EventID,
	  AlarmType,
	  AlarmAssignmentStatusID,
	  AlarmAssignmentStatusName,
	  EventName,	  
		Longitude,
		Latitude,
    [Address],
    OffenderID,
    NoteCount,
    AlarmID,
    GpsValid,
    GpsValidSatellites,
    GeoRule,
    SO,
    OPR,
    OfficerID,
    AgencyID,
    AcceptedDate,
    AcceptedBy,
    ActivateDate,
    DeactivateDate,
    EventParameter,
    EventTypeGroupID,
    OffenderName,
    OffenderDeleted
	)
	SELECT EventPrimaryID,
	       DeviceID,
	       EventTime,
	       EventDateTime,
         ReceivedTime,
         TrackerNumber,
         EventID,
         AlarmType,
         AlarmAssignmentStatusID,
         AlarmAssignmentStatusName,
         EventName,	  
         Longitude,
         Latitude,
         [Address],
         OffenderID,
         NoteCount,
         AlarmID,
         GpsValid,
         GpsValidSatellites,
         GeoRule,
         SO,
         OPR,
         OfficerID,
         AgencyID,
         AcceptedDate,
         AcceptedBy,
         ActivateDate,
         DeactivateDate,
         EventParameter,
         EventTypeGroupID,
         OffenderName,
         OffenderDeleted
	FROM #tmpMoveToBucket3 

	-- // Delete original records from Bucket2 // --
	DELETE FROM rprtEventsBucket2 WHERE EventPrimaryID IN (SELECT EventPrimaryID FROM #tmpMoveToBucket3)	
	
		-- // Clean Up // --
	DROP TABLE #tmpMoveToBucket3
	
	-- // Return Record Count // --
	SELECT @MovedRecordCount  
		
  /* *********** Error Handler ******************* */
  IF @@ERROR <> 0 OR @@TRANCOUNT = 0 
    BEGIN 
      IF @@TRANCOUNT > 0 
        ROLLBACK TRAN;
        SET NOEXEC ON 
    END
	
	-- // Commit Tran // --
	IF @@TRANCOUNT > 0
	  COMMIT TRAN;

  SET NOEXEC OFF  
END
GO

GRANT VIEW DEFINITION ON [spTPal_Evt_MoveToBucket3] TO [db_object_def_viewers]
GO

GRANT EXECUTE ON [spTPal_Evt_MoveToBucket3] TO [db_dml]
GO
USE [TrackerPal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[mTrackerDeactivate]
        
		@TrackerActivationID INT,
	@TrackerID INT,
	@OffenderID INT,
	@OfficerID INT,
	@ModifiedByID INT,
	@TrackerDeactivationReasonID INT,
	@TrackerDeactivationReasonSubTypeID INT,
	@ReasonText VARCHAR(100),
	@DeactivateDate DATETIME OUTPUT,
	@ApprovedByID INT

AS

SET @DeactivateDate = GETDATE()

SELECT @TrackerActivationID = TrackerActivationID
FROM OffenderTrackerActivation
WHERE 
	TrackerID = @TrackerID
   AND OffenderID = @OffenderID
   AND OfficerID = @OfficerID
   AND DeActivateDate IS NULL

UPDATE OffenderTrackerActivation
SET 
	DeActivateDate = @DeactivateDate,
   ModifiedByID = @ModifiedByID, 
   TrackerDeactivationReasonID = @TrackerDeactivationReasonID, 
   TrackerDeactivationReasonSubTypeID = @TrackerDeactivationReasonSubTypeID,
   ReasonText = @ReasonText,
   ApprovedById = @ApprovedByID

WHERE 
	TrackerID = @TrackerID
   AND OffenderID = @OffenderID
   AND OfficerID = @OfficerID
   AND DeActivateDate IS NULL

UPDATE OffenderServiceBilling
SET EndDate = @DeactivateDate, Active = 0 Where Offenderid = @Offenderid AND Active = 1

GO
GRANT EXECUTE ON [mTrackerDeactivate] TO [db_dml]
GO

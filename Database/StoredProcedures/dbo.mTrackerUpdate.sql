USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mTrackerUpdate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mTrackerUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   mTrackerUpdate.sql
 * Created On: Unknown
 * Created By: R.Cole
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: R.Cole - 02/08/2010
 *              Brought up to Standard
 * ******************************************************** */
CREATE PROCEDURE [mTrackerUpdate] (
	@TrackerID INT,
	@AgencyID	INT,
	@IsDemo	BIT,
  @FirmwareVersion INT,
	@ModifiedByID INT,
	@TrackerUniqueID INT = NULL OUTPUT
)
AS

SELECT TOP 1 @TrackerUniqueID = TrackerUniqueID 
FROM Tracker 
WHERE TrackerID = @TrackerID
  AND Deleted = 0 
ORDER BY CreatedDate

UPDATE Tracker
SET AgencyID = @AgencyID,
		IsDemo = @IsDemo,
    TrackerVersion = @FirmwareVersion,
		ModifiedDate = GETDATE(), 
		ModifiedByID = @ModifiedByID            
WHERE	TrackerUniqueID = @TrackerUniqueID
GO

GRANT EXECUTE ON [mTrackerUpdate] TO [db_dml]
GO

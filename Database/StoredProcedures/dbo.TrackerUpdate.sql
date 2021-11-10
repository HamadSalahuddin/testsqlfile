USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[TrackerUpdate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrackerUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   TrackerUpdate.sql
 * Created On: Unknown        
 * Created By: R.Cole
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: R.Cole - 02/08/2010
 *              Brought up to Standard
 * ******************************************************** */
CREATE PROCEDURE [TrackerUpdate] (
	@TrackerID INT,
	@AgencyID INT,
	@ModifiedByID	INT,
	@TrackerUniqueID INT = NULL OUTPUT
)
AS

SELECT TOP 1 @TrackerUniqueID = TrackerUniqueID 
FROM Tracker 
WHERE @TrackerID = TrackerID 
  AND Deleted = 0 
ORDER BY CreatedDate

UPDATE Tracker
SET AgencyID = @AgencyID,
		ModifiedDate = GETDATE(), 
		ModifiedByID = @ModifiedByID
WHERE	TrackerUniqueID = @TrackerUniqueID
GO

GRANT EXECUTE ON [TrackerUpdate] TO [db_dml]
GO

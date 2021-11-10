USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[TrackerDelete]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrackerDelete]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   TrackerDelete.sql
 * Created On: Unknown
 * Created By: R.Cole
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: R.Cole - 02/08/2010
 *              Brought up to Standard, added 
 *              TrackerUniqueID condition so that only
 *              the latest Tracker Assignment is updated.
 * ******************************************************** */
CREATE PROCEDURE [TrackerDelete] (
	@TrackerID INT,
	@ModifiedByID	INT,
	@TrackerUniqueID INT = NULL OUTPUT
)
AS

SELECT TOP 1 @TrackerUniqueID = TrackerUniqueID 
FROM Tracker 
WHERE @TrackerID = TrackerID 
  AND Deleted = 0 
ORDER BY CreatedDate

UPDATE	Tracker
SET Deleted = 1,
		ModifiedDate = GETDATE(),
		ModifiedByID = @ModifiedByID
WHERE	TrackerID = @TrackerID 
  AND Deleted = 0
  AND TrackerUniqueID = @TrackerUniqueID
GO

GRANT EXECUTE ON [TrackerDelete] TO [db_dml]
GO

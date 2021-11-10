USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mTrackerDelete]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mTrackerDelete]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   <mTrackerDelete.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: R.Cole - 02/08/2010
 *              Brought up to Standard and added check
 *              so that only the current Tracker
 *              Assignment is updated.
 * ******************************************************** */
CREATE PROCEDURE [mTrackerDelete] (
        @TrackerID INT,
        @ModifiedByID INT
)
AS

UPDATE Tracker
SET Deleted = 1,
    ModifiedDate = GETDATE(),
    ModifiedByID = @ModifiedByID
WHERE TrackerID = @TrackerID 
  AND Deleted = 0
  AND TrackerUniqueID = (SELECT TOP 1 TrackerUniqueID
                         FROM Tracker
                         WHERE TrackerID = @TrackerID
                           AND Deleted = 0
                         ORDER BY CreatedDate)
GO

GRANT EXECUTE ON [mTrackerDelete] TO [db_dml]
GO

USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[TrackerIsDemoUpdate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrackerIsDemoUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   TrackerIsDemoUpdate.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: R.Cole - 02/08/2010
 *              Brought up to Standard and added condition
 *              to prevent updating more than one row.
 * ******************************************************** */
CREATE PROCEDURE [TrackerIsDemoUpdate] (
	@TrackerID INT,
	@AgencyID INT,
	@IsDemo	BIT,
	@ModifiedByID	INT
)
AS

UPDATE	Tracker
SET IsDemo = @IsDemo,
		ModifiedDate = GETDATE(), 
		ModifiedByID = @ModifiedByID
WHERE	TrackerID = @TrackerID 
  AND AgencyID = @AgencyID 
  AND Deleted = 0
  AND TrackerUniqueID = (SELECT TOP 1 TrackerUniqueID 
                         FROM Tracker 
                         WHERE TrackerID = @TrackerID
                           AND AgencyID = @AgencyID
                           AND Deleted = 0 
                         ORDER BY CreatedDate)                           
GO

GRANT EXECUTE ON [TrackerIsDemoUpdate] TO [db_dml]
GO


USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetByTrackerID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetByTrackerID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetByTrackerID.sql
 * Created On: 03/29/2012
 * Created By: R.Cole
 * Task #:     3045
 * Purpose:    Get the offender based on a TrackerID               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetByTrackerID] (
  @TrackerID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT DISTINCT TrackerAssignment.OffenderID
FROM Tracker (NOLOCK)
  LEFT OUTER JOIN TrackerAssignment ON Tracker.TrackerID = TrackerAssignment.TrackerID
              AND TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment ta WHERE ta.TrackerID = Tracker.TrackerID)
WHERE Tracker.TrackerID = @TrackerID
  AND TrackerAssignment.TrackerAssignmentTypeID = 1     -- Ensure device is still assigned to offender

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetByTrackerID] TO db_dml;
GO
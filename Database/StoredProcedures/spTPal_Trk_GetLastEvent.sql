USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Trk_GetLastEvent]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Trk_GetLastEvent]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Trk_GetLastEvent.sql
 * Created On: 03/28/2012
 * Created By: R.Cole
 * Task #:     3045
 * Purpose:    Get the last/latest event for a device so
 *             we can attach a deactivation note to the event.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Trk_GetLastEvent] (
  @TrackerID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT MAX(EventPrimaryID) AS EventPrimaryID,
       EventTime,
       EventID       
FROM rprtEventsBucket1 (NOLOCK)
WHERE DeviceID = @TrackerID
  AND EventTime = (SELECT MAX(EventTime) FROM rprtEventsBucket1 WHERE DeviceID = @TrackerID)           
GROUP BY EventPrimaryID,
         EventTime,
         EventID

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Trk_GetLastEvent] TO db_dml;
GO
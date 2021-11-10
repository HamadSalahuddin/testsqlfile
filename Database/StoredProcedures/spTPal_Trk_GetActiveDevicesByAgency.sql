USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Trk_GetActiveDevicesByAgency]    Script Date: 03/03/2015 07:46:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Trk_GetActiveDevicesByAgency.sql
 * Created On: 02/28/2015
 * Created By: H.Salahuddin
 * Task #:     7638
 * Purpose:    Get the list of active devices by Agency             
 *
 * Modified By: R.Cole - 3/2/2015:  Added commented samples for getting the active devices for an agency.
 *				H.Salahuddin- 03/03/2015: Use the Query syntax provided by Ron.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Trk_GetActiveDevicesByAgency] 
	@AgencyID Int
AS
BEGIN	
  SELECT Offender.OffenderID,
         Offender.FirstName,
         Offender.LastName,
         ota.TrackerID
  FROM Trackerpal.dbo.OffenderTrackerActivation ota
    INNER JOIN Trackerpal.dbo.Offender ON ota.OffenderID = Offender.OffenderID
    INNER JOIN Trackerpal.dbo.Agency ON Offender.AgencyID = Agency.AgencyID
    INNER JOIN Trackerpal.dbo.Tracker ON ota.TrackerID = Tracker.TrackerID
  WHERE Agency.AgencyID = @AgencyID
    AND TrackerActivationID = (SELECT MAX(TrackerActivationID)    -- Ensure latest Activation
                               FROM Trackerpal.dbo.OffenderTrackerActivation ta
                               WHERE ta.TrackerID = ota.TrackerID) 
    AND ota.DeactivateDate IS NULL                                -- Active Devices ONLY    
    AND Tracker.Deleted = 0
    AND Offender.Deleted = 0
    AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Trackerpal.dbo.Tracker t WHERE t.TrackerID = Tracker.TrackerID)   -- Ensure we are using the latest Tracker/Agency assignment combo

  END

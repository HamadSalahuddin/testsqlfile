SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_dev_GetActiveDevicesByAgency.sql
 * Created On: 02/28/2015
 * Created By: H.Salahuddin
 * Task #:     7638
 * Purpose:    Get the list of active devices by Agency             
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE spTPal_dev_GetActiveDevicesByAgency 
	@AgencyID Int
AS
BEGIN	
	SET NOCOUNT ON;

    Select ofn.OffenderID
	,FirstName
	,LastName
	,ofn.TrackerID		
From Trackerpal.dbo.Agency agn
	 Inner Join Trackerpal.dbo.Tracker t on agn.AgencyID = t.AgencyID
	 Inner Join Trackerpal.dbo.TrackerAssignment ta on t.TrackerID = ta.TrackerID
	 And ta.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerPal.dbo.TrackerAssignment ta WHERE ta.TrackerID = t.TrackerID)
	 Inner Join Trackerpal.dbo.Offender ofn on ta.OffenderID = ofn.OffenderID
Where agn.Deleted = 0
And	  ofn.Deleted = 0
And	  t.Deleted = 0
And   agn.AgencyID = @AgencyID -- agency Parameter
And   ta.TrackerAssignmentTypeID = 1 -- Assigned
END
GO

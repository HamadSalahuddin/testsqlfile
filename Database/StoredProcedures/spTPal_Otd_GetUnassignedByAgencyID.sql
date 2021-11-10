USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Otd_GetUnassignedByAgencyID]    Script Date: 03/25/2016 14:04:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Otd_GetUnassignedByAgencyID.sql
 * Created On: 03/7/2012         
 * Created By: R.Cole  
 * Task #:     3024
 * Purpose:    Return data to the TrackerPal V2 Offender
 *             quick add screen               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Otd_GetUnassignedByAgencyID] (
  @AgencyID INT,
 	@GatewayPort VARCHAR(10),
	@GatewayIP VARCHAR(20)
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Main Query // --
SELECT Tracker.TrackerID,TrackerNumber,
       LEFT(TrackerName,8) AS [SerialNumber]
FROM Tracker
	LEFT JOIN TrackerAssignment ON TrackerAssignment.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID)
			                                                                    FROM TrackerAssignment ta 
			                                                                    WHERE ta.TrackerID = Tracker.TrackerID)
	LEFT JOIN Gateway.dbo.DeviceProperties dp1 ON dp1.DeviceID = Tracker.TrackerID AND dp1.PropertyID = '8410'
	LEFT JOIN Gateway.dbo.DeviceProperties dp2 ON dp2.DeviceID = Tracker.TrackerID AND dp2.PropertyID = '8411'
WHERE Tracker.Deleted = 0 
	AND Tracker.RmaID IS NULL 
  AND Tracker.AgencyID = @AgencyID
  AND ((TrackerAssignmentTypeID IS NULL) OR (TrackerAssignmentTypeID = 2))
	AND (dp1.PropertyValue = @GatewayIP AND dp2.PropertyValue = @GatewayPort)
--	AND (dp1.PropertyValue = @GatewayIP AND dp2.PropertyValue = @GatewayPort)  

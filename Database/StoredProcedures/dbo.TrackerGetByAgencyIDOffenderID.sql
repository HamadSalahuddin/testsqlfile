/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerGetByAgencyIDOffenderID]

	@AgencyID		int = -1,
	@OffenderID		int = 0,
	@GatewayPort	varchar(10),
	@GatewayIp		varchar(20),
	@CapabilityID	int = 0

AS

SELECT	distinct
	t.[TrackerID],[TrackerNumber]--,[AgencyID],t.[CreatedDate],[CreatedByID],[ModifiedDate],[ModifiedByID],[Deleted],[RmaID]
FROM	
	[Tracker] t
	INNER JOIN trackerversion tv ON t.TrackerVersion = tv.ID
	INNER JOIN trackerversioncapability tvc ON tv.ID = tvc.VersionID
	INNER JOIN trackercapability tc ON tvc.CapabilityID = tc.CapabilityID
	LEFT JOIN [TrackerAssignment] ta ON ta.TrackerAssignmentID = 
		(
			SELECT MAX(TrackerAssignmentID) -- MAX(AssignmentDate) -- 
			FROM [TrackerAssignment] ta 
			WHERE ta.TrackerID = t.TrackerID
		)
	LEFT JOIN Gateway.dbo.DeviceProperties dp1 ON dp1.DeviceID = t.TrackerID AND dp1.propertyID = '8410'
	LEFT JOIN Gateway.dbo.DeviceProperties dp2 ON dp2.DeviceID = t.TrackerID AND dp2.propertyID = '8411'
WHERE	
	t.Deleted = 0 
	AND RmaID IS NULL 

	-- Devices for all agencies OR for specified agency.
	AND (@AgencyID = -1 OR t.AgencyID = @AgencyID) 

	AND 
	(
		-- All unassigned devices
		TrackerAssignmentTypeID IS NULL OR TrackerAssignmentTypeID = 2  
		OR
		-- (the OR operator joins in this case) any device currently assigned to the specified offender.
		(TrackerAssignmentTypeID = 1 AND ta.OffenderID = @OffenderID)
	)	

	AND (dp1.PropertyValue = @GatewayIp AND dp2.PropertyValue = @GatewayPort)
	AND (dp1.PropertyValue = @GatewayIp AND dp2.PropertyValue = @GatewayPort)
	AND (@CapabilityID = 0 OR tc.CapabilityID = @CapabilityID)
	
	ORDER BY TrackerNumber
	
GO
GRANT VIEW DEFINITION ON [TrackerGetByAgencyIDOffenderID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [TrackerGetByAgencyIDOffenderID] TO [db_dml]
GO
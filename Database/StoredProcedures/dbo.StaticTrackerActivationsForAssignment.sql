/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [StaticTrackerActivationsForAssignment]
	@TrackerID bigint,
	@OffenderID bigint


AS

BEGIN

	SET NOCOUNT ON;

	select TrackerActivationID,OffenderID from OffenderTrackerActivation  where TrackerID=@TrackerID
		and OffenderID=@OffenderID
		

END


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
GRANT VIEW DEFINITION ON [StaticTrackerActivationsForAssignment] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [StaticTrackerActivationsForAssignment] TO [db_dml]
GO

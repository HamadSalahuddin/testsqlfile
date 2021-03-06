/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetTrackersActivated]
	
	@StartDate		DateTime,
	@EndDate		DateTime,
	@OffenderID		Int

AS

	SELECT	
		TrackerId, ActivateDate, DeActivateDate	
	FROM
		OffenderTrackerActivation
	WHERE	
		OffenderID = @OffenderID
		AND 
		(
--			(@StartDate = 0 and @EndDate = 0)
--			or
--			(
				(ActivateDate <= @EndDate AND DeActivateDate >= @StartDate)
				OR
				(ActivateDate <= @EndDate AND DeActivateDate IS NULL)
--			)
		)
		ORDER BY ActivateDate DESC
	
GO
GRANT VIEW DEFINITION ON [OffenderGetTrackersActivated] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderGetTrackersActivated] TO [db_dml]
GO

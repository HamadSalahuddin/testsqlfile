/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleScheduleUpdate]

	@GeoRuleScheduleID	INT,
	@AlwaysOn			BIT,
	@StartTime			SMALLINT,
	@EndTime			SMALLINT,
	@Sunday				BIT,
	@Monday				BIT,
	@Tuesday			BIT,
	@Wednesday			BIT,
	@Thursday			BIT,
	@Friday				BIT,
	@Saturday			BIT

AS

	UPDATE	GeoRuleSchedule
	SET		AlwaysOn = @AlwaysOn,
			StartTime = @StartTime,
			EndTime = @EndTime,
			Sunday = @Sunday,
			Monday = @Monday,
			Tuesday = @Tuesday,
			Wednesday = @Wednesday,
			Thursday = @Thursday,
			Friday = @Friday,
			Saturday = @Saturday
	WHERE	GeoRuleScheduleID = @GeoRuleScheduleID
GO
GRANT EXECUTE ON [GeoRuleScheduleUpdate] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [GeoRuleScheduleUpdate] TO [db_object_def_viewers]
GO

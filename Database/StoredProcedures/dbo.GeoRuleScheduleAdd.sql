/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleScheduleAdd]

	@GeoRuleScheduleID	INT OUTPUT,
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

	INSERT INTO GeoRuleSchedule
	(AlwaysOn, StartTime, EndTime, Sunday, Monday, Tuesday, Wednesday,
	 Thursday, Friday, Saturday)
	VALUES
	(@AlwaysOn, @StartTime, @EndTime, @Sunday, @Monday, @Tuesday, @Wednesday,
	 @Thursday, @Friday, @Saturday)

	SET @GeoRuleScheduleID = @@IDENTITY
GO
GRANT VIEW DEFINITION ON [GeoRuleScheduleAdd] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GeoRuleScheduleAdd] TO [db_dml]
GO
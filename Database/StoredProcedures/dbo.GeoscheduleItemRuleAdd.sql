/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoscheduleItemRuleAdd]
	@GeoScheduleItemId	uniqueidentifier ,
	@RuleData			xml 
AS
 
SET NOCOUNT ON;
BEGIN
	BEGIN TRAN
		INSERT INTO GeoscheduleItemRule    (GeoScheduleItemId,Id,RuleData)
		VALUES (@GeoScheduleItemId,NewId() ,@RuleData)
	COMMIT TRAN
END






GO
GRANT EXECUTE ON [GeoscheduleItemRuleAdd] TO [db_dml]
GO

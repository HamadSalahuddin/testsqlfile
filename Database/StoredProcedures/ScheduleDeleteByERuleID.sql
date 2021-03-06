/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ScheduleDeleteByERuleID]
	@ERuleID INT
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION

	DELETE  dbo.ScheduleRepeatedDay
	WHERE   ScheduleID IN (Select s.ID from Schedule s inner join [Rule]r ON s.RuleID=r.ID inner join ERule e ON e.RuleID=r.ID  where e.ID=@ERuleID)
	
    DELETE  dbo.Schedule
	WHERE   RuleID=(Select r.ID from [Rule] r inner join ERule e ON e.RuleID=r.ID where e.ID=@ERuleID)

COMMIT TRANSACTION
END






GO
GRANT EXECUTE ON [ScheduleDeleteByERuleID] TO [db_dml]
GO

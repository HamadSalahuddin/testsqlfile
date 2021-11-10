/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ScheduleGetByERuleID]
@ERuleID	INT

AS

	SET NOCOUNT ON

	SELECT s.id ,s.StartDateTime,s.EndDateTime,s.AlwaysOn,dbo.ConcatDaysID(s.ID)as 'DayIDs',dbo.ConcatDaysLetter(s.ID)as 'Days'
	FROM	Schedule s
    inner join [Rule] r ON r.ID = s.RuleID
    inner join ERule e ON e.RuleID = r.ID
    WHERE   e.ID=@ERuleID
	





GO
GRANT EXECUTE ON [ScheduleGetByERuleID] TO [db_dml]
GO
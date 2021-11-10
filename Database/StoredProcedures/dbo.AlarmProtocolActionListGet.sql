/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmProtocolActionListGet]

	@RoleID	INT, 
    @AgencyID INT, 
    @AlarmProtocolEventID INT

AS

	SELECT	apal.AlarmProtocolActionListID, apal.AlarmProtocolActionList
	FROM	AlarmProtocolActionList apal left join dbo.AgencyProtocolActionsAllowed a on apal.AlarmProtocolActionListID=a.AlarmProtocolActionListID
	WHERE	RoleID <= @RoleID  
            and (apal.AlarmProtocolActionListID<>'8'or((a.agencyID=@AgencyID)and(@AlarmProtocolEventID='6' or @AlarmProtocolEventID='7' or @AlarmProtocolEventID='10' or @AlarmProtocolEventID='9')))
    order by displayorder
GO
GRANT EXECUTE ON [AlarmProtocolActionListGet] TO [db_dml]
GO
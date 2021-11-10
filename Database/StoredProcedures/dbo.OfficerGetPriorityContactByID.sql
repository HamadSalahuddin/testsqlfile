/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OfficerGetPriorityContactByID]
@OfficerID int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
PriorityContactType1,
PriorityContactType2,
PriorityContactType3,
PriorityContactType4,
PriorityContactName1,
PriorityContactName2,
PriorityContactName3,
PriorityContactName4,
PriorityContactPhone1,
PriorityContactPhone2,
PriorityContactPhone3,
PriorityContactPhone4,
PriorityContactEmail1,
PriorityContactEmail2,
PriorityContactEmail3,
PriorityContactEmail4
FROM PriorityContact
WHERE OfficerID = @OfficerID

END

GO
GRANT EXECUTE ON [OfficerGetPriorityContactByID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OfficerGetPriorityContactByID] TO [db_object_def_viewers]
GO

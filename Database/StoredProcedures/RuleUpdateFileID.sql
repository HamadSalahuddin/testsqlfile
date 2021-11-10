/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [RuleUpdateFileID]

	@RuleID					INT,
	@FileID					INT

AS

	UPDATE	[Rule]
	SET		FileID = @FileID,
			UpdateInProgress = 1  
	WHERE	 ID = (Select r.ID from [Rule] r inner join ERule e ON e.RuleID=r.ID where e.ID=@RuleID)
GO
GRANT EXECUTE ON [RuleUpdateFileID] TO [db_dml]
GO

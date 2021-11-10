/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ERuleStatusUpdate]

	@ID	                   INT,
	@StatusID              INT


AS
BEGIN

	UPDATE	 dbo.[Rule]
	SET		 UploadStatusID= @StatusID		 	  
	WHERE	 ID = (Select r.ID from [Rule] r inner join ERule e ON e.RuleID=r.ID where e.ID=@ID)
    
END





GO
GRANT EXECUTE ON [ERuleStatusUpdate] TO [db_dml]
GO
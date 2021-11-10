/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [RuleUpdateStatus]  
  
 @RuleID     INT,  
 @StatusID     INT  
  
AS  
  
 IF @StatusID != 4 BEGIN   
  UPDATE [Rule]  
  SET  UploadStatusID = @StatusID,  
    UpdateInProgress = 0  
  WHERE ID = @RuleID  
 END  
 ELSE  
  UPDATE [Rule]  
  SET  UploadStatusID = @StatusID,  
    UpdateInProgress = 1  
  WHERE ID = @RuleID
GO
GRANT EXECUTE ON [RuleUpdateStatus] TO [db_dml]
GO
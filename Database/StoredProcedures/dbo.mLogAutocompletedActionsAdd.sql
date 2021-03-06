/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mLogAutocompletedActionsAdd]
@GUID nvarchar(50),  
@AlarmID int,  
@AlarmProtocolActionId int,
@ActionStatusId int,  
@DN nvarchar(20),  
@DailedDate datetime = NULL,  
@DailedStatus nvarchar(50),  
@IVR nvarchar(50),  
@IncidentID nvarchar(7)  
   
AS  
BEGIN  
   
 SET NOCOUNT ON;     
INSERT INTO LogAutocompletedActions   
(GUID,AlarmID,AlarmProtocolActionId,StatusID,DN,DailedDate,DailedStatus,IVR,CreatedDate, IncidentID)   
VALUES(@GUID,@AlarmID,@AlarmProtocolActionId,@ActionStatusId,@DN,@DailedDate,@DailedStatus,@IVR,GETDATE(),@IncidentID)  
  
END  
  

GO
GRANT EXECUTE ON [mLogAutocompletedActionsAdd] TO [db_dml]
GO

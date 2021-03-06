/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAutocompletedActionsTimedOutGetAll]      
      
  @sec bigint          
AS          
          
 SET NOCOUNT ON          
          
 SELECT     LogAutocompletedActions.GUID,LogAutocompletedActions.DN, 'TimeOut' as DailedStatus , 'TimeOut' as IVR,        
            CONVERT(nvarchar, LogAutocompletedActions.AlarmID) + '_' + CONVERT(nvarchar,LogAutocompletedActions.AlarmProtocolActionId) AS CacheID           
                               
 FROM         LogAutocompletedActions INNER JOIN          
                      AlarmProtocolAction ON LogAutocompletedActions.AlarmProtocolActionId = AlarmProtocolAction.AlarmProtocolActionID          
 WHERE     (LogAutocompletedActions.DailedDate IS NULL) AND (AlarmProtocolAction.Action = 'AutoCall')and (DateDIff(ss,LogAutocompletedActions.CreatedDate,GETDATE() )>= @sec)      
            and LogAutocompletedActions.StatusID <> 0 


update LogAutocompletedActions set statusid=0 where convert(nvarchar(50),LogAutocompletedActions.GUID) + '-' + LogAutocompletedActions.DN 
in ( SELECT     convert(nvarchar(50),LogAutocompletedActions.GUID) + '-' +LogAutocompletedActions.DN 
from      LogAutocompletedActions INNER JOIN          
                      AlarmProtocolAction ON LogAutocompletedActions.AlarmProtocolActionId = AlarmProtocolAction.AlarmProtocolActionID          
 WHERE     (LogAutocompletedActions.DailedDate IS NULL) AND (AlarmProtocolAction.Action = 'AutoCall')and (DateDIff(ss,LogAutocompletedActions.CreatedDate,GETDATE() )>= @sec)      
            and LogAutocompletedActions.StatusID <> 0 )
GO
GRANT EXECUTE ON [mAutocompletedActionsTimedOutGetAll] TO [db_dml]
GO

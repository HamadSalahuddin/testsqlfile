/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [BeaconThresholdGetByOffenderID]  
 @OffenderID         INT  ,
 @ThresholdID  INT OUTPUT
    
AS  

BEGIN  
set @ThresholdID=0
SELECT @ThresholdID= BeaconThresholdID
from dbo.OffenderBeaconThreshold    
where offenderID= @OffenderID


END  
GO
GRANT EXECUTE ON [BeaconThresholdGetByOffenderID] TO [db_dml]
GO

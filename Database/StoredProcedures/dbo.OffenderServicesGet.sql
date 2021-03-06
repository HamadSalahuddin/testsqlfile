/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderServicesGet] @OffenderID INT  
AS  
  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
SELECT a.OffenderID, a.FirstName + ' ' + a.LastName Offender, s.ServiceName  
FROM Offender a INNER JOIN OffenderServices asr ON a.OffenderID = asr.OffenderID  
INNER JOIN Services s ON asr.ServiceID = s.ServiceID  
WHERE a.OffenderID = @OffenderID  
  
  
    
GO
GRANT EXECUTE ON [OffenderServicesGet] TO [db_dml]
GO

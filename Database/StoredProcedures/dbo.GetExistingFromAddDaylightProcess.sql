/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GetExistingFromAddDaylightProcess] 
AS
SELECT DaylightUpdateProgressID,
       TrackerID,
       OffenderID
FROM DaylightUpdateProgress
WHERE FileID IS NULL
  and offenderID <> 29016
ORDER BY DayLightUpdateProgressID

GO
GRANT EXECUTE ON [GetExistingFromAddDaylightProcess] TO [db_dml]
GO
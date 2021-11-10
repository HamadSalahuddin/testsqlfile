/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AgencyServiceAttributesDelete] @AgencyID INT, @ServiceID INT, @AttributeName VARCHAR(MAX)  
AS  
  
BEGIN TRAN  
UPDATE AgencyServices  
SET ServiceAttributes.modify('delete (/ServiceAttributes/Attribute[@Name=sql:variable("@AttributeName")])')  
WHERE AgencyID = @AgencyID AND ServiceID = @ServiceID  
COMMIT TRAN

GO
GRANT EXECUTE ON [AgencyServiceAttributesDelete] TO [db_dml]
GO

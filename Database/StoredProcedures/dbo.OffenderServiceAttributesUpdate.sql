/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderServiceAttributesUpdate] @OffenderID INT, @ServiceID INT, @AttributeName VARCHAR(MAX), @NewValue VARCHAR(MAX)  
AS  
  
--Procedure only updates a particular service attribute within  
--the xml document.  
BEGIN TRAN  
UPDATE OffenderServices  
SET ServiceAttributes.modify('replace value of(/ServiceAttributes/Attribute[@Name=sql:variable("@AttributeName")]/AttributeValue/text())[1] with sql:variable("@NewValue")')  
WHERE OffenderID = @OffenderID AND ServiceID = @ServiceID   
COMMIT TRAN  
  
  
  
  
    
GO
GRANT EXECUTE ON [OffenderServiceAttributesUpdate] TO [db_dml]
GO

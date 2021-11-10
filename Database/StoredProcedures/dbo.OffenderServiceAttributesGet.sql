/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderServiceAttributesGet] @OffenderID INT, @ServiceID INT  
AS  
--Since the services attributes are in xml format, this procedure will return them in dataset format  
--so as to reduce the amount of processing on the business layer.  
  
DECLARE @hDoc INT  
DECLARE @Xml XML  
  
  
SET @Xml = (SELECT ServiceAttributes FROM OffenderServices WHERE OffenderID = @OffenderID AND ServiceID = @ServiceID)  
  
EXEC sp_xml_preparedocument @hDoc OUTPUT, @Xml  
  
SELECT @OffenderID AS OffenderID, @ServiceID AS ServiceID,  
  * FROM OPENXML(@hDoc,'/ServiceAttributes/Attribute',2)  
      WITH(AttributeName VARCHAR(MAX) './@Name',  
     DataType VARCHAR(35),  
     AttributeValue VARCHAR(MAX))  
  
EXEC sp_xml_removedocument @hDoc  
  
  
  
  
    
GO
GRANT EXECUTE ON [OffenderServiceAttributesGet] TO [db_dml]
GO

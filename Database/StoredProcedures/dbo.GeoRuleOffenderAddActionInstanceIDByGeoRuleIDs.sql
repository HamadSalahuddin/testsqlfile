/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleOffenderAddActionInstanceIDByGeoRuleIDs] (
  @OffenderID INT,
  @geoRulesID VARCHAR(MAX), 
  @ActionInstanceID BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
  
  DECLARE @id INT  
  DECLARE MyCursor CURSOR fast_forward   
    FOR SELECT number FROM GetTableFromListId( @geoRulesID )  
  
  BEGIN TRAN   
      OPEN MyCursor  
      FETCH NEXT FROM MyCursor  
      INTO @id  
 
      WHILE @@fetch_status = 0 AND @id > 0  
          BEGIN  
            -- Perform Operations  
            UPDATE GeoRule_Offender 
              SET ActionInstanceID = @ActionInstanceID
              WHERE OffenderID = @OffenderID AND GeoRuleID = @id
  
            -- Advance the Cursor            
            FETCH NEXT FROM MyCursor  
            INTO @id  
          END  
   
  CLOSE MyCursor  
  DEALLOCATE MyCursor  
        
  IF @@ERROR <> 0  
    BEGIN  
      ROLLBACK Tran  
    END  
  COMMIT TRAN  
  RETURN 0 
END

GO
GRANT EXECUTE ON [GeoRuleOffenderAddActionInstanceIDByGeoRuleIDs] TO [db_dml]
GO

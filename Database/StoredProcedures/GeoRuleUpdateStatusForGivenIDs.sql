USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GeoRuleUpdateStatusForGivenIDs]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleUpdateStatusForGivenIDs]
GO

-- =============================================    
-- Author:  <Sajid Abbasi>    
-- Create date: <25-Nov-2009>    
-- Description: <This stored procedure is a wraper on GeoRuleUpdateStatus stored procedure    
-- It updates Status ID to Failed=5 if upload process fails.  
-- =============================================    

CREATE PROCEDURE [dbo].[GeoRuleUpdateStatusForGivenIDs] (
  @geoRulesID VARCHAR(MAX), 
  @StatusID INT
)
    
AS    
BEGIN 
 SET NOCOUNT ON;    

DECLARE @id INT    
DECLARE MyCursor CURSOR FAST_FORWARD     
FOR SELECT number FROM GetTableFromListId( @geoRulesID )    
    
BEGIN TRAN     
  OPEN MyCursor    
  FETCH NEXT FROM MyCursor    
  INTO @id    
     
  WHILE @@fetch_status = 0 AND @id > 0    
    BEGIN    
      -- Perform Operations    
      EXEC GeoRuleUpdateStatus @id, @StatusID    
      
      -- Advance the Cursor    
      FETCH NEXT FROM MyCursor    
      INTO @id    
    END    
     
  CLOSE MyCursor    
  DEALLOCATE MyCursor    
  IF @@ERROR <> 0    
    BEGIN    
      ROLLBACK TRAN    
    END    
  COMMIT TRAN      
  RETURN 0 
END
GO

GRANT EXECUTE ON [dbo].[GeoRuleUpdateStatusForGivenIDs] TO db_dml;
GO
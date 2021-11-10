/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
-- =============================================  
-- Author:  <Sajid Abbasi>  
-- Create date: <20-Nov-2009>  
-- Description: <This stored procedure is a wraper on GeoRule_OffenderUpdateZoneID stored procedure  
-- It makes calls for all the GeoRules IDs that are going to be modified.>  
-- =============================================    
CREATE PROCEDURE [GeoRuleOffenderUpdateZoneIDForGivenIDs]
    @geoRulesID Varchar(MAX)   
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;  
    
    DECLARE @id int  
    DECLARE @iZoneID int  
    SET @iZoneID = 1  

    DECLARE MyCursor cursor fast_forward   
    For SELECT number from GetTableFromListId( @geoRulesID )  
  
    Begin TRAN   
        Open MyCursor  
        Fetch next From MyCursor  
        INTO @id  
   
        WHILE @@fetch_status = 0 AND @id > 0  
            Begin  
                -- Perform Operations  
                Exec GeoRule_OffenderUpdateZoneID @id, @iZoneID   
                Set @iZoneID = @iZoneID + 1  
                -- Advance the Cursor  
                Fetch next From MyCursor  
                INTO @id  
            End  
   
        Close MyCursor  
        DEALLOCATE MyCursor  
        
        IF @@ERROR <> 0  
        BEGIN  
            ROLLBACK Tran  
        END  
    COMMIT TRAN  
    Return 0  
    -- SABBASI        
END

GO
GRANT EXECUTE ON [GeoRuleOffenderUpdateZoneIDForGivenIDs] TO [db_dml]
GO
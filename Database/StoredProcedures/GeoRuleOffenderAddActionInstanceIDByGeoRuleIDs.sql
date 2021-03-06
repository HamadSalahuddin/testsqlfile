USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GeoRuleOffenderAddActionInstanceIDByGeoRuleIDs]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleOffenderAddActionInstanceIDByGeoRuleIDs]
GO

-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 14-Jan-2010
-- Description:	This procedure adds ActionInstanceID for the georule that are uploaded.
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GeoRuleOffenderAddActionInstanceIDByGeoRuleIDs] (
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

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleOffenderAddActionInstanceIDByGeoRuleIDs] TO db_dml;
GO

USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleLibraryAddSchedules]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleLibraryAddSchedules]
GO

USE TrackerPal
GO

set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Sajid Abbasi>  
-- Create date: <09-Dec-2009>  
-- Description: <This stored adds schedules in GeoRuleLibrary item for a libraryitemID
  
-- =============================================  
CREATE PROCEDURE [dbo].[GeoRuleLibraryAddSchedules] 
@geoRuleLibItemID int, 
@geoRulesScheduleIDs Varchar(MAX)   
  
AS  
BEGIN  
SET NOCOUNT ON;  
-------- Here first get values from GeoRuleLibraryTable for given itemID----------
DECLARE @tempT TABLE 
(
	GeoRuleGeoZoneID 	int,
	RuleTypeID 			int,
	AgencyID 			int,
	CreatedByID			int,
	ModifiedDate		DateTime,
	ModifiedByID		int,
    GeoRuleLibraryItemName varchar(50)
);
DECLARE @GeoRuleLibraryItemName varchar(50),
@GeoRuleGeoZoneID 	int,
@RuleTypeID 		int,
@AgencyID 			int,
@CreatedByID		int,
@ModifiedByID		int,
@GeoRuleLibraryItemID int

INSERT @tempT (GeoRuleGeoZoneID, RuleTypeID, AgencyID, CreatedByID,
				ModifiedByID,GeoRuleLibraryItemName)

( 
						SELECT top 1 GeoRuleGeoZoneID, RuleTypeID, AgencyID, CreatedByID,
						ModifiedByID,GeoRuleLibraryItemName  FROM GeoRuleLibrary WHERE GeoRuleLibraryItemID=@geoRuleLibItemID
)

SELECT @GeoRuleLibraryItemName = GeoRuleLibraryItemName, @RuleTypeID = RuleTypeID,
@AgencyID = AgencyID, @CreatedByID = CreatedByID,@GeoRuleGeoZoneID = GeoRuleGeoZoneID,
@ModifiedByID = @ModifiedByID, @GeoRuleLibraryItemName = GeoRuleLibraryItemName
FROM @tempT

-----------------------------------------------------------------------------------


DECLARE @id int  
DECLARE MyCursor cursor fast_forward   
For  
SELECT number from GetTableFromListId( @geoRulesScheduleIDs )  
  
Begin TRAN   
Open MyCursor  
Fetch next From MyCursor  
INTO @id  
   
WHILE @@fetch_status = 0 AND @id > 0  
Begin  
  -- Perform Operations  
  Exec GeoRuleLibraryAdd @GeoRuleLibraryItemID output , @GeoRuleGeoZoneID , @id, --@geoRuleLibItemID
@RuleTypeID, @AgencyID, @CreatedByID, @ModifiedByID,
@GeoRuleLibraryItemName,@geoRuleLibItemID    
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
--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleLibraryAddSchedules] TO db_dml;
GO


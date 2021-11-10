USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleLibraryDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleLibraryDelete]
GO

USE TrackerPal
GO


-- =============================================  
-- Author:  Sajid Abbasi  
-- Create date: 14-Dec-2009  
-- Description: Deletes geo rule from GeoRuleRuleLibraryItem. The procedure first deletes references from  
-- GeoRuleGeoZone and GeoRuleSchedule and GeoRuleReferencePointID.   
-- =============================================  
  
CREATE PROCEDURE [dbo].[GeoRuleLibraryDelete]  
 @AgencyID int,  
    @GeoRuleLibraryItemName varchar(50)  
AS  
BEGIN  
 SET NOCOUNT ON;  
   
DECLARE @tempT Table (GeoRuleGeoZoneID int, GeoRuleScheduleID int)  
 INSERT @tempT(GeoRuleGeoZoneID, GeoRuleScheduleID)  
 (SELECT GeoRuleGeoZoneID,GeoRuleScheduleID FROM GeoRuleLibrary  
   WHERE AgencyID = @AgencyID AND GeoRuleLibraryItemName LIKE @GeoRuleLibraryItemName )  
  
  
 BEGIN TRAN  
       
    
    DELETE FROM GeoRuleSchedule WHERE GeoRuleScheduleID   
   in ( SELECT GeoRuleScheduleID FROM @tempT)  
  
  IF @@ERROR <> 0  
  BEGIN  
   ROLLBACK TRAN  
   return 1  
  END  
  
  --Delete Reference records tied to GeoRuleLibrary geoRule!   
  DELETE FROM GeoRuleReferencePoint   
  WHERE GeoRuleReferencePointID in (SELECT GeoRuleReferencePointID FROM GeoRuleGeoZone   
   WHERE GeoRuleGeoZoneID in ( SELECT GeoRuleGeoZoneID FROM @tempT))  
    
  IF @@ERROR <> 0  
  BEGIN  
   ROLLBACK TRAN  
   return 2  
  END  
  
  --Delete GeoRuleGeoZone records tied to GeoRuleLibrary geoRule   
  DELETE FROM GeoRuleGeoZone WHERE GeoRuleGeoZoneID   
  in ( SELECT GeoRuleGeoZoneID FROM @tempT)    
  
  IF @@ERROR <> 0  
  BEGIN  
   ROLLBACK TRAN  
   return 3  
  END  
  
--Delete georule from GeoRuleLibrary   
 DELETE FROM GeoRuleLibrary  
 WHERE AgencyID = @AgencyID AND GeoRuleLibraryItemName LIKE @GeoRuleLibraryItemName   
  
  IF @@ERROR <> 0  
  BEGIN  
   ROLLBACK TRAN  
   return 4  
  END  
  
  
 COMMIT TRAN  
  
 RETURN 0  
END  
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleLibraryDelete]  TO db_dml;
GO  
  
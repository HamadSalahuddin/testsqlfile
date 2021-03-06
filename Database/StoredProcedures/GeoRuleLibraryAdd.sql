USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleLibraryAdd]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleLibraryAdd]
GO

USE TrackerPal
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   GeoRuleLibraryAdd.sql
 * Created On: 07-Dec_2009
 * Created By: S.Abbasi
 * Task #:     
 * Purpose:    The procedure adds GeoRuleLibrary item.               
 *
 * Modified By: R.Cole - 24-Jan-2011: Removed the logic to 
 *                explicitly set the ID in the table.  The 
 *                ID column in the table is set to auto-increment
 *                and has a seed of 1.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[GeoRuleLibraryAdd] (
    @GeoRuleLibraryItemID INT OUTPUT, 
    @GeoRuleGeoZoneID INT, 
    @GeoRuleScheduleID INT, 
    @RuleTypeID INT, 
    @AgencyID INT, 
    @CreatedByID INT, 
    @ModifiedByID INT, 
    @GeoRuleLibraryItemName VARCHAR(50),
    @id INT = 0             -- Not needed after 1/24/11 fix
)
AS
BEGIN
  INSERT INTO GeoRuleLibrary (
    GeoRuleGeoZoneID , 
		GeoRuleScheduleID, 
		RuleTypeID, 
		AgencyID, 
		CreatedByID, 
		ModifiedByID, 
		GeoRuleLibraryItemName
	)
	VALUES ( 
	  @GeoRuleGeoZoneID , 
		@GeoRuleScheduleID, 
		@RuleTypeID,  
		@AgencyID, 
		@CreatedByID, 
		@ModifiedByID, 
		@GeoRuleLibraryItemName
	)
			
  SET @GeoRuleLibraryItemID = @@IDENTITY

END
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleLibraryAdd] TO db_dml;
GO
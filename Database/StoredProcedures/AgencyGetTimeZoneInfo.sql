USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AgencyGetTimezoneInfo]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AgencyGetTimezoneInfo]
GO
/* ***************************************************
   * FileName:    AgencyGetTimezoneInfo.sql
   * Created On:  Unknown                              
   * Created By:  Aculis, Inc
   * Task #:		  <Redmine #>                           
   * Purpose:     Returns Agency Specific TimeZone Info
   *                                                  
   * Modified By: R.Cole - 01/12/2010
   *              Removed Select * and brought SP up
   *              standard
   ************************************************* */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AgencyGetTimezoneInfo] (
	@AgencyID INT
)
AS

BEGIN
	SET NOCOUNT ON;

	SELECT TimeZone.TimeZoneID,
	       TimeZone.Name,
	       TimeZone.UtcOffset,
	       TimeZone.DaylightUtcOffset,
	       TimeZone.DisplayOrder,
	       TimeZone.Deleted,
		     Agency.DaylightSavings
	FROM TimeZone 
		LEFT JOIN Agency ON Agency.TimeZoneID = TimeZone.TimeZoneID 
		      AND Agency.AgencyID = @AgencyID
	WHERE AgencyID = @AgencyID
END
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[AgencyGetTimezoneInfo] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_GetStreetAddressCache]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_GetStreetAddressCache]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Evt_GetStreetAddressCache.sql
 * Created On: 07-Sep-2011         
 * Created By: SABBASI  
 * Task #:     Redmine #      
 * Purpose:    Get the Lat/Long and Address from the cache               
 *
 * Modified By: R.Cole - 9/9/2011: Added DROP IF EXISTS and
 *                GRANT stmts.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Evt_GetStreetAddressCache] 	
AS
BEGIN
	SET NOCOUNT ON;

  SELECT CAST (CAST(Latitude AS VARCHAR)+ ',' + CAST(Longitude AS VARCHAR) AS VARCHAR) AS 'Coordinate', 
         StreetAddress AS 'Address' 
  FROM ReverseGeoCode_StreetAddressCache
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Evt_GetStreetAddressCache] TO db_dml;
GO

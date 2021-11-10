USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[ReverseGeoCode_GetEventsWithoutAddresses]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReverseGeoCode_GetEventsWithoutAddresses]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   ReverseGeoCode_GetEventsWithoutAddresses.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     
 * Purpose:    Get events to Geocode               
 *
 * Modified By: R.Cole - 6/20/2011 - Cleaned code and removed
 *                old commented out code.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[ReverseGeoCode_GetEventsWithoutAddresses] (
	@RowCount INT = 1000
)
AS

DECLARE @Table TABLE (Latitude BIGINT, Longitude BIGINT, Address VARCHAR(200), EventPrimaryID BIGINT, CacheHits INT, DateRetrieved DATETIME, EventDateTime DATETIME)
DECLARE @CurrentDate DATETIME
SET @CurrentDate = GETDATE()

-- // Get Events to GeoCode // --
INSERT INTO @Table 
	SELECT DISTINCT TOP (@RowCount) FLOOR(bucket1.Latitude * 100000), FLOOR(bucket1.Longitude * 100000), NULL, bucket1.EventPrimaryID, 0, @CurrentDate, bucket1.EventDateTime
	FROM dbo.rprtEventsBucket1 bucket1 WITH(NOLOCK)
	WHERE bucket1.Address IS NULL
	ORDER BY bucket1.EventDateTime DESC

-- // Update the number of CacheHits // --
UPDATE ReverseGeoCode_StreetAddressCache 
	SET CacheHits = cache.CacheHits + 1
	FROM @Table tbl 
	  INNER JOIN ReverseGeoCode_StreetAddressCache cache ON tbl.Latitude = cache.Latitude
			     AND tbl.Longitude = cache.Longitude

-- // Update tablevar with the cached address // --
UPDATE @Table
	SET CacheHits = cache.CacheHits,
		Address = cache.StreetAddress
	FROM @Table tbl 
		INNER JOIN ReverseGeoCode_StreetAddressCache cache ON tbl.Latitude = cache.Latitude
			     AND tbl.Longitude = cache.Longitude

-- Return results to the Geocoder // --
SELECT * FROM @Table 
GO

GRANT EXECUTE ON [ReverseGeoCode_GetEventsWithoutAddresses] TO [db_dml];
GO
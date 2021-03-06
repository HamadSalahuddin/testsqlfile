/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReverseGeoCode_GetEventsWithoutAddresses]

	@RowCount int = 1000

AS

DECLARE @Table TABLE (Latitude bigint, Longitude bigint, Address varchar(200), EventPrimaryID bigint, CacheHits int, DateRetrieved datetime, EventDateTime datetime)
DECLARE @CurrentDate datetime
SET @CurrentDate = GETDATE()

INSERT INTO @Table 
	SELECT DISTINCT TOP (@RowCount) FLOOR(a.Latitude * 100000), FLOOR(a.Longitude * 100000), NULL, a.EventPrimaryID, 0, @CurrentDate, a.EventDateTime
	FROM dbo.rprtEventsBucket1 a WITH(NOLOCK)
	WHERE a.Address IS NULL

UPDATE ReverseGeoCode_StreetAddressCache 
	SET
		CacheHits = s.CacheHits + 1
	FROM
		@Table a 
		INNER JOIN ReverseGeoCode_StreetAddressCache s ON a.Latitude = s.Latitude
			AND a.Longitude = s.Longitude

UPDATE @Table
	SET 
		CacheHits = s.CacheHits,
		Address = s.StreetAddress
	FROM 
		@Table a 
		INNER JOIN ReverseGeoCode_StreetAddressCache s ON a.Latitude = s.Latitude
			AND a.Longitude = s.Longitude


--	WHERE EXISTS (
--		SELECT s.Latitude FROM StreetAddressCache s
--		WHERE Latitude = s.Latitude AND Longitude = s.Longitude
--	)

SELECT * FROM @Table --ORDER BY EventDateTime DESC

--INSERT INTO dbo.StreetAddressCache (Latitude, Longitude)
--	SELECT DISTINCT TOP @RowCount ROUND(a.Latitude, 5), ROUND(a.Longitude, 5)
--	FROM dbo.rprtEventsBucket1 a
--	WHERE NOT EXISTS (
--		SELECT s.Latitude FROM StreetAddressCache s
--		WHERE ROUND(a.Latitude, 5) = s.Latitude
--		AND ROUND(a.Longitude, 5) = s.Longitude
--	)





GO
GRANT EXECUTE ON [ReverseGeoCode_GetEventsWithoutAddresses] TO [db_dml]
GO

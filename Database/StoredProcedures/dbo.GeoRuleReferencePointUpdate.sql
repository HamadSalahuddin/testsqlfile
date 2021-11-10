/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleReferencePointUpdate]

	@Street						NVARCHAR(50),
	@City						NVARCHAR(50),
	@StateID					INT,
	@PostalCode					NVARCHAR(25),
	@CountryID					INT,
	@Longitude					FLOAT,
	@Latitude					FLOAT,
   @Georuleid					INT

AS

UPDATE GeoRuleReferencePoint
SET Street = @Street, City=@City, Stateid = @Stateid, PostalCode = @Postalcode
,Countryid = @Countryid, Longitude = @Longitude, Latitude = @Latitude
where GeoRuleReferencePointID IN (Select GeoRuleReferencePointID From Georule where Georuleid = @Georuleid)


GO
GRANT EXECUTE ON [GeoRuleReferencePointUpdate] TO [db_dml]
GO

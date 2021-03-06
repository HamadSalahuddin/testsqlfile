/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [SetAddress]
        @Latitude       float,
        @Longitude      float,
        @Address        varchar(100)

AS
BEGIN

	UPDATE dbo.StreetAddressCache
	SET
	StreetAddress =  @Address
	WHERE Latitude = @Latitude
	AND Longitude = @Longitude

	UPDATE	dbo.rprtEventsBucket1
	SET 
	Address = @Address
	WHERE round(Latitude, 5) = @Latitude
	AND round(Longitude, 5) = @Longitude
END

GO
GRANT VIEW DEFINITION ON [SetAddress] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [SetAddress] TO [db_dml]
GO

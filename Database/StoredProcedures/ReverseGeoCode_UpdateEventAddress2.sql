/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReverseGeoCode_UpdateEventAddress2]

	@Address varchar(200),
	@EventPrimaryID bigint = -1

AS

UPDATE dbo.rprtEventsBucket2
	SET Address = @Address
	WHERE 
		(@EventPrimaryID > 0 AND EventPrimaryID = @EventPrimaryID)

GO
GRANT EXECUTE ON [ReverseGeoCode_UpdateEventAddress2] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReverseGeoCode_UpdateEventAddress2] TO [db_object_def_viewers]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mOffenderArchive]
	@OffenderID		INT,
	@ModifiedByID	INT
AS
BEGIN

	UPDATE Offender
	SET	Deleted = 1,
		ModifiedDate = GETDATE(),
		ModifiedByID = @ModifiedByID
	WHERE OffenderID = @OffenderID

END


GO
GRANT EXECUTE ON [mOffenderArchive] TO [db_dml]
GO

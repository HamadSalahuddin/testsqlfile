/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetNotes]

	@OffenderID		INT,
	@Notes			NVARCHAR(2000) OUTPUT

AS

	SELECT	@Notes = Notes
	FROM	Offender
	WHERE	OffenderID = @OffenderID
GO
GRANT VIEW DEFINITION ON [OffenderGetNotes] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderGetNotes] TO [db_dml]
GO

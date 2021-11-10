/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [Offender_OfficerUpdate]

	@OffenderID INT,
	@OfficerID	INT

AS

SET NOCOUNT ON

UPDATE [dbo].[Offender_Officer] SET

	OfficerID = @OfficerID

WHERE OffenderID = @OffenderID
GO
GRANT VIEW DEFINITION ON [Offender_OfficerUpdate] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [Offender_OfficerUpdate] TO [db_dml]
GO

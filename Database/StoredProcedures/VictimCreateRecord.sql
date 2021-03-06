/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [VictimCreateRecord]
	@CreatedByID int,
	@AgencyID int,
	@VictimID int OUTPUT

AS
BEGIN
SET NOCOUNT ON;
	
INSERT INTO [dbo].[Offender] (
	[CreatedDate],
	[CreatedByID],
	[AgencyID],
	[Victim],
	[Deleted]
) 
VALUES 
(
	GETDATE(),
	@CreatedByID,
	@AgencyID,
	1,
	0
)

SET @VictimID = SCOPE_IDENTITY()

END
GO
GRANT EXECUTE ON [VictimCreateRecord] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [VictimCreateRecord] TO [db_object_def_viewers]
GO

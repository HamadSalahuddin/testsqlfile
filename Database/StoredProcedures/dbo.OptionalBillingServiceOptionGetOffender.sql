/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OptionalBillingServiceOptionGetOffender]
@OffenderID INT
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT BillingServiceOptionID,OffenderID,BeaconCount
FROM dbo.OptionalBillingServiceOptionOffender
WHERE OffenderID = @OffenderID

GO
GRANT EXECUTE ON [OptionalBillingServiceOptionGetOffender] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerBillableAdd] 
	@BillableID int OUTPUT,
	@TrackerID int,
	@CreatedByID int,
	@AuthorizedByID int,
	@InvoiceNumber varchar(25),
	@Status	int,
	@AgencyID int
AS
BEGIN
	SET NOCOUNT ON;



INSERT INTO [TrackerBillable] 
	(TrackerID, CreatedByID, CreatedDate, AuthorizedByID, InvoiceNumber, Status) 
VALUES
	(@TrackerID, @CreatedByID, GETDATE(), @AuthorizedByID, @InvoiceNumber, @Status)

SET @BillableID = @@IDENTITY

UPDATE [Tracker]
SET 
	[BillableID] = @@IDENTITY, deleted = 0, agencyid = @AgencyID
WHERE
        CreatedDate = (SELECT MAX(CreatedDate) FROM Tracker WHERE TrackerID = @TrackerID)



END
GO
GRANT VIEW DEFINITION ON [TrackerBillableAdd] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [TrackerBillableAdd] TO [db_dml]
GO

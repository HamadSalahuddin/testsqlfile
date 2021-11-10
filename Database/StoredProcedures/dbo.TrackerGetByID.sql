/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [TrackerGetByID]

	@TrackerID	INT = -1,
	@TrackerUniqueId int=-1,
	@GetDeleted BIT = 0

AS

	SELECT
		t.TrackerUniqueID,
		ISNULL(ta.OffenderID,0) AS offenderID, 
		t.TrackerID, 
		t.TrackerNumber, 
		t.AgencyID, 
		a.Agency, 
		t.IsDemo, 
		t.BillableID, 
		t.CreatedDate,
		t.CreatedByID,
		t.ModifiedDate,
		t.ModifiedByID,
		tb.AuthorizedByID, 
		opr.LastName + ', ' + opr.FirstName AS 'AuthorizedByName',
		tb.InvoiceNumber,
		tb.Status AS 'Billable',
		t.Deleted
	FROM	
		Tracker t
		LEFT JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID
			AND ta.AssignmentDate = (SELECT MAX(AssignmentDate) FROM TrackerAssignment ta WHERE ta.TrackerID = t.TrackerID)
		LEFT JOIN Agency a ON t.AgencyID = a.AgencyID
		LEFT JOIN TrackerBillable tb ON tb.TrackerBillableID = t.BillableID
		LEFT JOIN Operator opr ON opr.UserID = tb.AuthorizedByID
--		LEFT JOIN TrackerBillable tb ON tb.TrackerID = t.TrackerID
--			AND tb.AuthorizedDate = (SELECT MAX(AuthorizedDate) FROM TrackerBillable tb WHERE tb.TrackerID = t.TrackerID)
	WHERE
		(
			(@TrackerID<0 )
			or
			(t.TrackerID = @TrackerID )
		)
		 and
		(
			(@TrackerUniqueId<0)
			 or 
			(@TrackerUniqueId=t.TrackerUniqueID)
		)

		AND (@GetDeleted = 1 OR t.Deleted = 0)
GO
GRANT EXECUTE ON [TrackerGetByID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [TrackerGetByID] TO [db_object_def_viewers]
GO
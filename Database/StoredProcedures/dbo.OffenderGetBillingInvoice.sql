/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetBillingInvoice]

	@OffenderID	INT

AS




SELECT 
ota.ActivateDate, ota.DeActivateDate, 
ISNULL(o.LastName + ', ', '') + ISNULL(o.FirstName, '') AS 'OffenderName', ota.TrackerID, 
ISNULL(ocr.FirstName + ', ', '') + ISNULL(ocr.LastName, '') AS 'OfficerName',
ag.Agency, ag.Streetline1, ag.Streetline2, ag.City, ag.StateID, ag.PostalCode, ag.Phone
FROM OffenderTrackerActivation ota
inner join Offender o
on o.OffenderID = ota.OffenderID
inner join Officer ocr
on ocr.OfficerID = ota.OfficerID
inner join Agency ag
on ag.AgencyID = ocr.AgencyID

WHERE ota.OffenderID = @OffenderID
GO
GRANT VIEW DEFINITION ON [OffenderGetBillingInvoice] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderGetBillingInvoice] TO [db_dml]
GO

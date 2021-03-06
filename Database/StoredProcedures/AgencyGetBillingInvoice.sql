/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AgencyGetBillingInvoice]

	@AgencyID	INT,
	@StartDate  DATETIME,
    @EndDate    DATETIME      

AS

BEGIN

SELECT DISTINCT
	ota.ActivateDate, 
	ota.DeActivateDate, 
	acc.BillingRate,
	acc.DiscountRate AS 'Discount',
	acc.BillingPer,
	0 AS 'Days',
	0 AS 'Amount',
	ISNULL(o.LastName + ', ', '') + ISNULL(o.FirstName, '') AS 'OffenderName', 
	o.BirthDate,
	t.TrackerNumber AS 'TrackerNumber',

--	(SELECT TrackerNumber FROM Tracker WHERE TrackerID = o.TrackerID AND AgencyID = ag.AgencyID) AS 'TrackerNumber1', 
--	(SELECT TOP(1) TrackerNumber FROM Tracker WHERE TrackerID = 
--		(SELECT TOP(1) TrackerID FROM TrackerAssignment WHERE OffenderID = o.OffenderID 
--			AND SupervisionOfficerID = ocr.OfficerID 
--			AND TrackerAssignmentTypeID = 1
--			AND AssignmentDate BETWEEN @StartDate AND @EndDate
--		)
--		--AND Deleted = 'false' 
--		AND AgencyID = ag.AgencyID
--	) AS 'TrackerNumber', 

	ISNULL(ocr.LastName + ', ', '') + ISNULL(ocr.FirstName, '') AS 'OfficerName',
	ag.Agency, 
	ag.Streetline1, 
	ag.Streetline2, 
	ag.City, 
	(SELECT Abbreviation FROM State st WHERE st.StateID = ag.StateID) AS 'StateID', 
	ag.PostalCode, 
	ag.Phone,
	acc.TaxRate AS 'tax', 
	acc.CustomerAccountID,
	o.OffenderID
FROM 
	OffenderTrackerActivation ota
	INNER JOIN Offender o ON o.OffenderID = ota.OffenderID 
	INNER JOIN Officer ocr ON ocr.OfficerID = ota.OfficerID 
	INNER JOIN Agency ag ON ag.AgencyID = ocr.AgencyID 
	INNER JOIN Tracker t ON t.TrackerID = ota.TrackerID 
	INNER JOIN Accounting acc ON acc.ID = ag.AgencyID 
	LEFT JOIN TimeZone tz ON tz.TimeZoneID = ag.TimeZoneID 
WHERE 
	ag.AgencyID = @AgencyID
	AND
	(
		(ota.ActivateDate < DATEADD(day,1,@EndDate) AND ota.DeActivateDate > @StartDate)
		OR
		(ota.ActivateDate < DATEADD(day,1,@EndDate) AND ota.DeActivateDate IS NULL)
	)
ORDER BY 
	ag.Agency, ISNULL(o.LastName + ', ', '') + ISNULL(o.FirstName, ''), ota.ActivateDate
	
END
GO
GRANT VIEW DEFINITION ON [AgencyGetBillingInvoice] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [AgencyGetBillingInvoice] TO [db_dml]
GO

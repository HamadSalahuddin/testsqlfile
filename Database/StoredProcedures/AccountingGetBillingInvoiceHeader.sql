/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AccountingGetBillingInvoiceHeader] 
	@CustomerID int = 0
AS
BEGIN
	SET NOCOUNT ON;

IF @CustomerID > 0

	BEGIN

	SELECT
		ag.Agency, 
		ag.Streetline1, 
		ag.Streetline2, 
		ag.City, 
		(SELECT Abbreviation FROM State st WHERE st.StateID = ag.StateID) AS 'StateID', 
		ag.PostalCode, 
		ag.Phone,
		acc.TaxRate AS 'tax', 
		acc.CustomerAccountID,

		--TODO: Make this work when daylight savings is no longer observed (sometime in Oct.)
		CASE
			WHEN
				ag.DaylightSavings IS NOT NULL AND ag.DaylightSavings > 0
			THEN
				tz.DaylightUtcOffset
			ELSE
				tz.UtcOffset
		END AS 'UtcOffset'

	FROM 
		Agency ag
		INNER JOIN Accounting acc ON acc.ID = ag.AgencyID AND acc.Deleted = 0
		LEFT JOIN TimeZone tz ON tz.TimeZoneID = ag.TimeZoneID AND tz.Deleted = 0
	WHERE 
		ag.AgencyID = @CustomerID

	END

ELSE

	BEGIN

	SELECT TOP (1)
		'ALL CUSTOMERS' AS 'Title',
		'[Billing Period]' AS 'BillingPeriod'	
	FROM
		Accounting

	END

END
GO
GRANT EXECUTE ON [AccountingGetBillingInvoiceHeader] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AccountingGetBillingInvoiceHeader] TO [db_object_def_viewers]
GO

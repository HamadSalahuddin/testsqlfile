/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AccountingGetCustomers]

AS

	SELECT
		DISTINCT ac.ID,
        ag.Agency AS 'CustomerName'
	FROM
		Accounting(NOLOCK) ac
		INNER JOIN Agency ag ON ag.AgencyID = ac.ID
	WHERE
		ac.CustomerType = 1 AND ac.Deleted = 0

UNION

	SELECT
		DISTINCT ac.ID,
        o.LastName + ', ' + o.FirstName AS 'CustomerName'
	FROM
		Accounting(NOLOCK) ac
		INNER JOIN Operator o ON o.UserID = ac.ID
		INNER JOIN [User] u ON u.UserTypeID = 1
	WHERE
		ac.CustomerType = 2 AND ac.Deleted = 0

UNION

	SELECT
		DISTINCT ac.ID,
        o.LastName + ', ' + o.FirstName AS 'CustomerName'
	FROM
		Accounting(NOLOCK) ac
		INNER JOIN Officer o ON o.OfficerID = ac.ID
		INNER JOIN [User] u ON u.UserTypeID = 2
	WHERE
		ac.CustomerType = 2 AND ac.Deleted = 0

UNION

	SELECT
		DISTINCT ac.ID,
        o.LastName + ', ' + o.FirstName AS 'CustomerName'
	FROM
		Accounting(NOLOCK) ac
		INNER JOIN Offender o ON o.OffenderID = ac.ID
	WHERE
		ac.CustomerType = 3 AND ac.Deleted = 0
GO
GRANT VIEW DEFINITION ON [AccountingGetCustomers] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [AccountingGetCustomers] TO [db_dml]
GO
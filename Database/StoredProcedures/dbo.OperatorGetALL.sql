/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OperatorGetALL]

AS
	SELECT	ISNULL(o.UserID, '') AS 'UserID',
			ISNULL(o.Title, '') AS 'Title',
			ISNULL(o.Department, '') AS 'Department',
			ISNULL(o.SalutationID, 0) AS 'SalutationID',
			ISNULL(o.FirstName, '') AS 'FirstName',
			ISNULL(o.MiddleName, '') AS 'MiddleName',
			ISNULL(o.LastName, '') AS 'LastName',
			ISNULL(o.SuffixID, 0) AS 'SuffixID',
			ISNULL(o.StreetLine1, '') AS 'StreetLine1',
			ISNULL(o.StreetLine2, '') AS 'StreetLine2',
			ISNULL(o.City, '') AS 'City',
			ISNULL(o.StateID, 1) AS 'StateID',
			ISNULL(o.PostalCode,'') AS 'PostalCode',
			ISNULL(o.CountryID, 1) AS 'CountryID',
			ISNULL(o.DayPhone, '') AS 'DayPhone',
			ISNULL(o.EveningPhone, '') AS 'EveningPhone',
			ISNULL(o.MobilePhone, '') AS 'MobilePhone',
			ISNULL(o.Fax, '') AS 'Fax',
			ISNULL(o.EmailAddress1, '') AS 'EmailAddress1',
			ISNULL(o.EmailAddress2, '') AS 'EmailAddress2'
	FROM	Operator o
	WHERE	o.Deleted = 0
	ORDER BY 'FirstName','MiddleName','LastName'
GO
GRANT VIEW DEFINITION ON [OperatorGetALL] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OperatorGetALL] TO [db_dml]
GO
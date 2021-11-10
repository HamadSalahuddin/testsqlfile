/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mOfficerGetByID]

	@OfficerID	INT,
	@GetDeleted BIT = 0

AS
BEGIN
	SELECT	u.UserID ,--AS 'OfficerUserID',
			u.UserName,
			u.UserPassword,
			u.UserPassCode,
			u.UserTypeID,
			u.CreatedDate,
			u.CreatedByID,
			u.ModifiedDate,
			u.ModifiedByID,
			ur.RoleID,
			o.OfficerID, 
			o.Deleted,			
			ISNULL(o.AgencyID, 0) AS 'AgencyID',
			ISNULL(o.Title,'') AS 'Title',
			ISNULL(o.Department,'') AS 'Department',
			ISNULL(o.SalutationID, '') AS 'SalutationID',
			ISNULL(o.FirstName, '') AS 'FirstName',
			ISNULL(o.MiddleName, '') AS 'MiddleName',
			ISNULL(o.LastName, '') AS 'LastName',
			ISNULL(o.SuffixID, '') AS 'SuffixID',
			ISNULL(o.StreetLine1,'') AS 'StreetLine1',
			ISNULL(o.StreetLine2,'') AS 'StreetLine2',
			ISNULL(o.City,'') AS 'City',
			ISNULL(o.StateID, 0) AS 'StateID',
			ISNULL(o.PostalCode,'') AS 'PostalCode',
			ISNULL(o.CountryID, 0) AS 'CountryID',
			ISNULL(o.DayPhone, '') AS 'DayPhone',
			ISNULL(o.EveningPhone, '') AS 'EveningPhone',
			ISNULL(o.MobilePhone, '') AS 'MobilePhone',
			ISNULL(o.Fax, '') AS 'Fax',
			ISNULL(o.PAger,'') AS 'Pager',
			ISNULL(o.EmailAddress1, '') AS 'EmailAddress1',
			ISNULL(o.EmailAddress2,'') AS 'EmailAddress2',
			ISNULL(o.SMSAddress, '') AS 'SMSAddress',
			ISNULL(o.SMSGatewayID,0) AS 'SMSGatewayID',
			ISnull(o.ExtDayPhone,'') AS 'ExtDayPhone',
			ISNULL(o.ExtEveningPhone,'') AS 'ExtEveningPhone' 
	FROM	Officer o
	INNER JOIN [User] u ON o.UserID = u.UserID
	INNER JOIN User_Role ur ON u.UserID = ur.UserID
	WHERE	o.OfficerID = @OfficerID AND (@GetDeleted = 1 OR o.Deleted = 0)

END

GO
GRANT EXECUTE ON [mOfficerGetByID] TO [db_dml]
GO

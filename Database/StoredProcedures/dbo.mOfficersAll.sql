/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mOfficersAll]
AS
BEGIN
	SELECT 
	u.UserID,
	u.UserName,
	u.UserPassword,
	u.UserPassCode,
	u.UserTypeID,
--	u.CreatedDate,	same as officer? BLL doesn't distinguish..
--	u.CreatedByID,
--	u.ModifiedDate,
--	u.ModifiedByID,
	ur.RoleID,
	o.AgencyID, 
	o.City, 
	o.CountryID, 
	o.CreatedByID, 
	o.CreatedDate, 
	o.DayPhone, 
	o.Deleted, 
	o.Department, 
	o.EmailAddress1, 
	o.EmailAddress2, 
	o.EveningPhone, 
	o.ExtDayPhone, 
	o.ExtEveningPhone, 
	o.Fax, 
	o.FirstName, 
	o.LastName, 
	o.MiddleName, 
	o.MobilePhone, 
	o.ModifiedByID, 
	o.ModifiedDate, 
	o.OfficerID, 
	o.Pager, 
	o.PostalCode, 
	o.SalutationID, 
	o.SMSAddress, 
	o.SMSGatewayID, 
	o.StateID, 
	o.StreetLine1, 
	o.StreetLine2, 
	o.SuffixID, 
	o.Title
	FROM Officer o 
		LEFT JOIN [User] u ON u.UserID = o.UserID 
		LEFT JOIN User_Role ur ON u.UserID = ur.UserID
	WHERE o.Deleted = 0 AND u.Deleted = 0
END
GO
GRANT EXECUTE ON [mOfficersAll] TO [db_dml]
GO

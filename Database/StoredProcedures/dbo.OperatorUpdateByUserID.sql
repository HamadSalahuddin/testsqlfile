/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OperatorUpdateByUserID]
	@iUserID int,
	@sTitle nvarchar(50) = null,
	@sDepartment nvarchar(50) = null,
	@iSalutationID int = null,
	@sFirstName nvarchar(50) = null,
	@sMiddleName nvarchar(50) = null,
	@sLastName nvarchar(50) = null,
	@iSuffixID int = null,
	@sStreetLine1 nvarchar(50) = null,
	@sStreetLine2 nvarchar(50) = null,
	@sCity nvarchar(50) = null,
	@iStateID int = null,
	@sPostalCode nvarchar(25) = null,
	@iCountryID int = null,
	@sDayPhone nvarchar(25) = null,
	@sEveningPhone nvarchar(25) = null,
	@sMobilePhone nvarchar(25) = null,
	@sPager varchar(25) = null,
	@sFax nvarchar(25) = null,
	@sEmailAddress1 nvarchar(50) = null,
	@sEmailAddress2 nvarchar(50) = null,
	@iModifiedByID int

AS

	UPDATE	Operator
	SET		Title = @sTitle,
			Department = @sDepartment,
			SalutationID = @iSalutationID,
			FirstName = @sFirstName,
			MiddleName = @sMiddleName,
			LastName = @sLastName,
			SuffixID = @iSuffixID,
			StreetLine1 = @sStreetLine1,
			StreetLine2 = @sStreetLine2,
			City = @sCity,
			StateID = @iStateID,
			PostalCode = @sPostalCode,			
			CountryID = @iCountryID,
			DayPhone = @sDayPhone,
			EveningPhone = @sEveningPhone,
			MobilePhone = @sMobilePhone,
			Pager = @sPager,
			Fax = @sFax,
			EmailAddress1 = @sEmailAddress1,
			EmailAddress2 = @sEmailAddress2,
			ModifiedDate = GETDATE(),
			ModifiedByID = @iModifiedByID
	WHERE	UserID = @iUserID
GO
GRANT EXECUTE ON [OperatorUpdateByUserID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OperatorUpdateByUserID] TO [db_object_def_viewers]
GO
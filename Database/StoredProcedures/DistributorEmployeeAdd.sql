/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DistributorEmployeeAdd]

	@DistributorEmployeeID	INT OUTPUT,
	@UserID			INT,
	@DistributorID	INT,
	@Title			NVARCHAR(50),
	@Department		NVARCHAR(50),
	@SalutationID	INT,
	@FirstName		NVARCHAR(50),
	@MiddleName		NVARCHAR(50),
	@LastName		NVARCHAR(50),
	@SuffixID		INT,
	@StreetLine1	NVARCHAR(50),
	@StreetLine2	NVARCHAR(50),
	@City			NVARCHAR(50),
	@StateID		INT,
	@PostalCode		NVARCHAR(25),
	@CountryID		INT,
	@DayPhone		NVARCHAR(25),
	@ExtDayPhone		NVARCHAR(25),
	@EveningPhone	NVARCHAR(25),
	@ExtEveningPhone	NVARCHAR(25),
	@MobilePhone	NVARCHAR(25),
	@Pager			NVARCHAR(25),
	@Fax			NVARCHAR(25),
	@EmailAddress	NVARCHAR(50),
	@EmailAddress2	NVARCHAR(50),
	@CreatedByID	INT

AS

	INSERT INTO DistributorEmployee
	(UserID, DistributorID, Title, Department, SalutationID, FirstName, MiddleName, LastName,
	 SuffixID, StreetLine1, StreetLine2, City, StateID, PostalCode, CountryID,
	 DayPhone, ExtDayPhone,EveningPhone,ExtEveningPhone, MobilePhone, Pager, Fax, EmailAddress,EmailAddress2, 
	 CreatedByID, CreatedDate, Deleted)
	VALUES
	(@UserID, @DistributorID, @Title, @Department, @SalutationID, @FirstName, @MiddleName, @LastName,
	 @SuffixID, @StreetLine1, @StreetLine2, @City, @StateID, @PostalCode, @CountryID,
	 @DayPhone,@ExtDayPhone, @EveningPhone,@ExtEveningPhone ,@MobilePhone, @Pager, @Fax, @EmailAddress, @EmailAddress2,
	 @CreatedByID, GetDate(), 0)

	SET @DistributorEmployeeID = @@IDENTITY
GO
GRANT VIEW DEFINITION ON [DistributorEmployeeAdd] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [DistributorEmployeeAdd] TO [db_dml]
GO

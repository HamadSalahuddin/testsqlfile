/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DistributorAdd]
	@DistributorID		INT OUTPUT,
	@TamID				INT,
	@DistributorName	NVARCHAR(50),
	@StreetLine1	NVARCHAR(50),
	@StreetLine2	NVARCHAR(50),
	@City			NVARCHAR(50),
	@StateID		INT,
	@PostalCode		NVARCHAR(25),
	@CountryID		INT,
	@Phone			NVARCHAR(25),
	@Fax			NVARCHAR(25),
	@URL			NVARCHAR(50),
	@EmailAddress	NVARCHAR(50),
	@CreatedByID	INT,
	@Assign bit,
    @Activate bit
AS
	INSERT INTO Distributor
	(DistributorName, StreetLine1, StreetLine2, City, StateID, PostalCode, 
	 CountryID, Phone, Fax, URL, EmailAddress, CreatedByID, CreatedDate, TamID,Assign,Activate)
	VALUES
	(@DistributorName, @StreetLine1, @StreetLine2, @City, @StateID, @PostalCode, 
	 @CountryID, @Phone, @Fax, @URL, @EmailAddress, @CreatedByID, GetDate(), @TamID,@Assign,@Activate)

	SET @DistributorID = @@IDENTITY
GO
GRANT EXECUTE ON [DistributorAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [DistributorAdd] TO [db_object_def_viewers]
GO
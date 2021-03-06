/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mVictimUpdate]
	@VictimID int,
	@ModifiedByID int,
	@AgencyID int,
	@OfficerID int,
	@FirstName NVARCHAR(50),
	@MiddleName NVARCHAR(50) = NULL,
	@LastName NVARCHAR(50),
	@BirthDate DATETIME,
	@ProxViolationDistance int,
	@ProxAlertDistance int = NULL,
	@AssociatedOffenderID int = NULL

--	@StreetLine1	NVARCHAR(50),
--	@StreetLine2	NVARCHAR(50),
--	@City			NVARCHAR(50),
--	@StateID		INT,
--	@PostalCode		NVARCHAR(25),
--	@CountryID		INT,
--	@Phone			NVARCHAR(25),
--	@EmailAddress	NVARCHAR(50),
AS

BEGIN

IF @OfficerID NOT IN (SELECT OfficerID FROM Offender_Officer WHERE OffenderID = @VictimID)
BEGIN

UPDATE Offender_Officer
SET
	OfficerID = @OfficerID
WHERE OffenderID = @VictimID

END 

UPDATE Offender
SET 
	ModifiedDate = GETDATE(),
	ModifiedByID = @ModifiedByID,
	AgencyID = @AgencyID,
	FirstName = @FirstName,
	MiddleName = @MiddleName,
	LastName = @LastName,
	BirthDate = @BirthDate,
	VictimProxViolationDistance = @ProxViolationDistance,
	VictimProxAlertDistance = @ProxAlertDistance,
	VictimAssociatedOffenderID = @AssociatedOffenderID

--	StreetLine1 = @StreetLine1,
--	StreetLine2 = @StreetLine2,
--	City = @City,
--	StateID = @StateID,
--	PostalCode = @PostalCode,
--	CountryID = @CountryID,
--	Phone = @Phone,
--	EmailAddress = @EmailAddress
WHERE OffenderID = @VictimID

END

GO
GRANT EXECUTE ON [mVictimUpdate] TO [db_dml]
GO

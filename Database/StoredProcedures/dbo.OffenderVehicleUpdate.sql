/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderVehicleUpdate]
	@iOffenderVehicleID int,
	@iOffenderID int,
	@sLicensePlate nvarchar(50) = null,
	@sMake nvarchar(50) = null,
	@sModel nvarchar(50) = null,
	@sYear nvarchar(5) = null,
	@sColor nvarchar(20) = null,
	@sSpecialMarkings nvarchar(2000) = null,
	@sRegisteredOwner nvarchar(50) = null,
	@sRegisteredOwnerPhone nvarchar(25) = null,
	@sVIN nvarchar(50) = null,
	@sLocationStreet1 nvarchar(100) = null,
	@sLocationStreet2 nvarchar(100) = null,
	@sLocationCity nvarchar(50) = null,
	@iLocationStateID int = null,
	@sLocationPostalCode nvarchar(50) = null,
	@iLocationCountryID int = null,
	@sInsuranceCompanyName nvarchar(50) = null,
	@sInsurancePolicyNumber nvarchar(50) = null,
	@sInsuranceAgent nvarchar(50) = null,
	@sInsurancePrimaryPhone nvarchar(25) = null,
	@sInsuranceFax nvarchar(25) = null


AS
BEGIN

	SET NOCOUNT ON;

	UPDATE OffenderVehicle SET
	OffenderID=@iOffenderID,
	LicensePlate=@sLicensePlate,
	Make=@sMake,
	Model=@sModel,
	Year=@sYear,
	Color=@sColor,
	SpecialMarkings=@sSpecialMarkings,
	RegisteredOwner=@sRegisteredOwner,
	RegisteredOwnerPhone=@sRegisteredOwnerPhone,
	VIN=@sVIN,
	LocationStreet1=@sLocationStreet1,
	LocationStreet2=@sLocationStreet2,
	LocationCity=@sLocationCity,
	LocationStateID=@iLocationStateID,
	LocationPostalCode=@sLocationPostalCode,
	LocationCountryID=@iLocationCountryID,
	InsuranceCompanyName=@sInsuranceCompanyName,
	InsurancePolicyNumber=@sInsurancePolicyNumber,
	InsuranceAgent=@sInsuranceAgent,
	InsurancePrimaryPhone=@sInsurancePrimaryPhone,
	InsuranceFax=@sInsuranceFax
	 
	WHERE OffenderVehicleID = @iOffenderVehicleID 

END
GO
GRANT VIEW DEFINITION ON [OffenderVehicleUpdate] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderVehicleUpdate] TO [db_dml]
GO

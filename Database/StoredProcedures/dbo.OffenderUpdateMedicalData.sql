/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderUpdateMedicalData]
	@iOffenderID int,
	@iBloodTypeID int = null,
	@sMedicalConditionsNotes nvarchar(2000) = null,
	@sMedicalAllergiesNotes nvarchar(2000) = null,
	@sMedicalMedicationsNotes nvarchar(2000) = null

AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Offender SET
	MedicalBloodTypeID = @iBloodTypeID,
	MedicalConditionNotes = @sMedicalConditionsNotes,
	MedicalAllergyNotes = @sMedicalAllergiesNotes,
	MedicalMedicationNotes = @sMedicalMedicationsNotes

	WHERE OffenderID = @iOffenderID

END



GO
GRANT VIEW DEFINITION ON [OffenderUpdateMedicalData] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderUpdateMedicalData] TO [db_dml]
GO

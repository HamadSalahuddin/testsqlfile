USE [TrackerPal]
GO

/****** Object:  StoredProcedure [dbo].[OffenderGetInfoByOffenderID]    Script Date: 08/04/2016 11:46:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* ******************************************************
 *   FileName:    OffenderGetInfoByOffenderID.sql
 *   Created On:  Unknown
 *   Created By:  Unknown
 *   Task #:      
 *   Purpose:     
 *   
 *   Modified By:  S.Abbasi 11/15/2010 - Added ReferralProgramID
 *                 R.Cole 11/16/2010 - Added IF EXISTS and
 *                  Grant STMTS. Reformatted per standard.
 *					       S.Abbasi 02/17/2012  Added ReferralProgramSubtypeID 
 *                  field with reference to Task #3055
 *                 Farrukh 8/2/102: Task#: 3994 - Added PoliceDistrictID
 *				   H.Salahuddin 10/Dec/2014 Task# 7458 -- Added Description field from PoliceDistrict,ProgramName
 *				   H.Salahuddin 11/Dec/2014 Task# 7458 -- Removed ProgramName reference and its table reference
 *				   S.KHALIQ 21 APR 2015 TASK # 6496 --  added ReferralProgramSubTypeOptionID field in the select statement
 *				   H.Salahuddin 03/Aug/2016 Task# 10592 Added ReferredFromID in the Select Clause.
 * **************************************************** */
CREATE PROCEDURE [dbo].[OffenderGetInfoByOffenderID] (
	@iOffenderID INT,
	@GetDeleted BIT = 1 -- Change this to 0 to allow filtering by Deleted field
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CASE WHEN ta.TrackerAssignmentTypeID = 1 THEN ta.TrackerID ELSE 0 END AS 'TrackerID',
		     o.[OffenderID],
		     o.[AgencyID],
		     o.[OffenderNumber],
		     o.[SalutationID],
		     o.[FirstName],
		     o.[MiddleName],
		     o.[LastName],
		     o.[Alias1],
		     o.[Alias2],
		     o.[Alias3],
		     o.[SuffixID],
		     o.[RiskLevelID],
		     o.[Notes],
		     o.[CaseNumber],
		     o.[FBINumber],
		     o.[SSN],
		     o.[OffenseTypeID],
		     o.[SentencingDurationStartDate],
		     o.[SentencingDurationEndDate],
		     o.[TrackingDurationStartDate],
		     o.[TrackingDurationEndDate],
		     o.[Height],
		     o.[HeightMeasurementID],
		     o.[Weight],
		     o.[WeightMeasurementID],
		     o.[HairColorID],
		     o.[EyeColorID],
		     o.[StrapSizeID],
		     o.[GenderID],
		     o.[EthnicityID],
		     o.[BirthDate],
		     o.[StatusID],
		     o.[MugPhotoName],
		     o.[HomeStreet1],
		     o.[HomeStreet2],
		     o.[HomeCity],
		     o.[HomeStateOrProvinceID],
		     o.[HomeCountryID],
		     o.[HomePostalCode],
		     o.[HomePhone1TypeID],
		     o.[HomePhone2TypeID],
		     o.[HomePhone3TypeID],
		     o.[HomePhone4TypeID],
		     o.[HomePhone1],
		     o.[HomePhone2],
		     o.[HomePhone3],
		     o.[HomePhone4],
		     o.[HomePropertyOwner],
		     o.[HomePropertyOwnerPhone],
		     o.[CaseCourtName],
		     o.[CaseJudgeName],
		     o.[CaseDistrictAttorney],
		     o.[CaseAssignedAgency],
		     o.[CaseNcicNumber],
		     o.[CaseBailBondAgent],
		     o.[CaseBailBondPhone],
		     o.[CaseBailBondAmount],
		     o.[CaseCriminalHistoryNotes],
		     o.[WorkCompanyName],
		     o.[WorkStreet1],
		     o.[WorkStreet2],
		     o.[WorkCity],
		     o.[WorkStateOrProvinceID],
		     o.[WorkCountryID],
		     o.[WorkPostalCode],
		     o.[WorkPhone1],
		     o.[WorkPhone2],
		     o.[WorkFax],
		     o.[WorkMobilePhone1],
		     o.[WorkMobilePhone2],
		     o.[WorkEmail1],
		     o.[WorkEmail2],
		     o.[WorkSupervisorName],
		     o.[WorkSupervisorPhone1],
		     o.[WorkSupervisorPhone2],
		     o.[WorkSupervisorFax],
		     o.[WorkSupervisorEmail],
		     o.[WorkSupervisorContactInfo],
		     o.[LicensePlate],
		     o.[VehicleRegistration],
		     o.[VehicleManufacturer],
		     o.[VehicleYear],
		     o.[VehicleModel],
		     o.[VehicleColor],
		     o.[VIN],
		     o.[VehicleRegisteredOwner],
		     o.[VehicleRegisteredOwnerPhone],
		     o.[VehiclePhotoName],
		     o.[VehicleLocationStreet1],
		     o.[VehicleLocationStreet2],
		     o.[VehicleLocationCity],
		     o.[VehicleLocationStateID],
		     o.[VehicleLocationCountryID],
		     o.[VehicleLocationPostalCode],
		     o.[VehicleSpecialMarkings],
		     o.[VehicleInsuranceCompanyName],
		     o.[VehicleInsuranceAgent],
		     o.[VehicleInsurancePolicyNumber],
		     o.[VehicleInsuranceStreet1],
		     o.[VehicleInsuranceStreet2],
		     o.[VehicleInsuranceCity],
		     o.[VehicleInsuranceStateOrProvinceID],
		     o.[VehicleInsuranceCountryID],
		     o.[VehicleInsurancePostalCode],
		     o.[VehicleInsurancePhone1],
		     o.[VehicleInsurancePhone2],
		     o.[VehicleInsuranceFax],
		     o.[VehicleInsuranceEmail1],
		     o.[VehicleInsuranceEmail2],
		     o.[VehicleInsuranceURL],
		     o.[MedicalBloodTypeID],
		     o.[MedicalMedicationNotes],
		     o.[MedicalAllergyNotes],
		     o.[MedicalConditionNotes],
		     o.[HealthCareCompanyName],
		     o.[DoctorName],
		     o.[HealthCareStreet1],
		     o.[HealthCareStreet2],
		     o.[HealthCareCity],
		     o.[HealthCareStateOrProvinceID],
		     o.[HealthCareCountryID],
		     o.[HealthCarePostalCode],
		     o.[HealthCarePhone1],
		     o.[HealthCarePhone2],
		     o.[HealthCareFax],
		     o.[HealthCareEmail1],
		     o.[HealthCareEmail2],
		     o.[HealthCareURL],
		     o.[HealthInsuranceCompanyName],
		     o.[HealthInsurancePolicyNumber],
		     o.[HealthInsuranceStreet1],
		     o.[HealthInsuranceStreet2],
		     o.[HealthInsuranceCity],
		     o.[HealthInsuranceStateOrProvinceID],
		     o.[HealthInsuranceCountryID],
		     o.[HealthInsurancePostalCode],
		     o.[HealthInsurancePhone1],
		     o.[HealthInsurancePhone2],
		     o.[HealthInsuranceFax],
		     o.[HealthInsuranceEmail1],
		     o.[HealthInsuranceEmail2],
		     o.[HealthInsuranceURL],
		     o.[OfficerContact1ID],
		     o.[OfficerContact2ID],
		     o.[OfficerContact3ID],
		     o.[OfficerContact4ID],
		     o.[OfficerContact5ID],
		     o.[CreatedDate],
		     o.[CreatedByID],
		     o.[ModifiedDate],
		     o.[ModifiedByID],
		     o.[Deleted],
		     o.[PrimaryLanguageID],
		     o.[HighProfileOffender],
		     ofof.OfficerID, 
		     ta.TrackerAssignmentID,
		     o.[Victim],
		     o.[VictimAssociatedOffenderID],
		     o.[VictimProxAlertDistance],
		     o.[VictimProxViolationDistance],
		     o.[OffenseSubTypeId],
		     o.[OffenderPay],
		     o.[ReferralProgramID],
         o.[ReferralProgramSubTypeID],
         o.[ReferralProgramSubTypeOptionID],
         o.[PoliceDistrictID],
         pd.[Description],
         o.[ReferredFromID]
	FROM [Offender] o
		LEFT JOIN [TrackerAssignment] ta ON ta.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) 
				                                                          FROM [TrackerAssignment] ta 
				                                                          WHERE ta.OffenderID = @iOffenderID)
		LEFT JOIN [Offender_Officer] ofof ON ofof.OffenderID = o.OffenderID
		LEFT JOIN [PoliceDistricts] pd ON o.PoliceDistrictID = pd.PoliceDistrictID
	
	WHERE	o.OffenderID = @iOffenderID 
	  AND (@GetDeleted = 1 OR o.Deleted = 0)
END

GO


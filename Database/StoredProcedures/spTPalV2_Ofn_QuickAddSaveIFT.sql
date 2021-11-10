/* **********************************************************
 * FileName:   spTPalV2_Ofn_QuickAddSaveIFT
 * Created On: 10/04/2014
 * Created By: H.Salahuddin
 * Task #:     #7050
 * Purpose:    Consolidate save into one procedure.
 * this also keeps from having to default data over the top
 * of existing data
 * Modified By: 
 * ******************************************************** */
CREATE PROCEDURE spTPalV2_Ofn_QuickAddSaveIFT 
	@iOffenderID INT,
	@dtBirthday DATETIME = Null,
	@iLanguageID INT = Null,
	@sHomeStreet1 NVARCHAR(50) = Null,
	@sHomeStreet2 NVARCHAR(50) = Null,
	@sHomeCity NVARCHAR(50) = Null,
	@iHomeStateID INT = Null,
	@sHomePostalCode NVARCHAR(25) = Null,
	@iHomeCountryID INT = Null,
	@sPhone1 NVARCHAR(25) = Null,
	@iAgencyID INT = Null,
	@FirstName NVARCHAR(50) = NULL,
	@LastName NVARCHAR(50) = NULL,
	@MiddleName NVARCHAR(50) = NULL,
	@TrackerDeviceID INT = NULL,
	@RiskLevelID INT = NULL,
	@OffenseTypeID INT = NULL,
	@ReferralProgramID INT,
	@ReferralProgramSubTypeID INT,
	@PoliceDistrictID INT =NULL,
	@OffenderNumber NVARCHAR(25)= NULL,
	@SentencingDurationStartDate DATETIME = NULL,
	@SentencingDurationEndDate   DATETIME = NULL,
	@CaseNumber NVARCHAR(25) =NULL,
	@SSN NVARCHAR(11) =NULL	
AS
BEGIN	
	SET NOCOUNT ON;
	    
	UPDATE Offender 
    SET	  BirthDate = @dtBirthday,
	      PrimaryLanguageID = @iLanguageID,
	      HomeStreet1 = @sHomeStreet1,
	      HomeStreet2 = @sHomeStreet2,
	      HomeCity = @sHomeCity,
	      HomeStateOrProvinceID = @iHomeStateID,
	      HomePostalCode =@sHomePostalCode,
	      HomeCountryID = @iHomeCountryID,
	      HomePhone1 = @sPhone1,
	      AgencyID=@iAgencyID,
		  FirstName = @FirstName,
          LastName = @LastName,
          MiddleName = @MiddleName,
          TrackerID = @TrackerDeviceID,
          RiskLevelID = @RiskLevelID,
          OffenseTypeID = @OffenseTypeID,
          ReferralProgramID = @ReferralProgramID,
		  ReferralProgramSubTypeID = @ReferralProgramSubTypeID,
		  PoliceDistrictID = @PoliceDistrictID,
		  OffenderNumber = @OffenderNumber,
		  SentencingDurationStartDate = @SentencingDurationStartDate,
		  SentencingDurationEndDate = @SentencingDurationEndDate,
		  CaseNumber = @CaseNumber,
		  SSN = @SSN
  
  WHERE   OffenderID = @iOffenderID
END
GO

USE [TrackerPal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   spTPalV2_Ofn_QuickAddSave
 * Created On: 06/06/2012
 * Created By: K.Griffiths
 * Task #:     #3401
 * Purpose:    Consolidate save into one procedure.
 * this also keeps from having to default data over the top
 * of existing data
 *
 * Modified By: R.Cole - 6/7/2012: Added DROP and GRANT stmts,
 *                Changed ALTER to CREATE for SVN version.
 *              R.Cole - 05/28/2013: Added PhoneTypeID to Update.
 *                This corrects the issue documented in #4034.
 * ******************************************************** */
create PROCEDURE [dbo].[spTPalV2_Ofn_QuickAddSave] (
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
	@TrackerDeviceID INT = NULL,
	@RiskLevelID INT = NULL,
	@OffenseTypeID INT = NULL,
	@ReferralProgramID INT,
  @ReferralProgramSubTypeID INT
)	
AS
SET NOCOUNT ON;
BEGIN

  DECLARE @HomePhone1TypeID INT
  SET @HomePhone1TypeID = 1                                  -- HomePhone

  UPDATE Offender 
    SET BirthDate = @dtBirthday,
	      PrimaryLanguageID = @iLanguageID,
	      HomeStreet1 = @sHomeStreet1,
	      HomeStreet2 = @sHomeStreet2,
	      HomeCity = @sHomeCity,
	      HomeStateOrProvinceID = @iHomeStateID,
	      HomePostalCode = @sHomePostalCode,
	      HomeCountryID = @iHomeCountryID,
        HomePhone1TypeID = @HomePhone1TypeID,
	      HomePhone1 = @sPhone1,
	      AgencyID = @iAgencyID,
        FirstName = @FirstName,
        LastName = @LastName,
        TrackerID = @TrackerDeviceID,
        RiskLevelID = @RiskLevelID,
        OffenseTypeID = @OffenseTypeID,
        ReferralProgramID = @ReferralProgramID,
		    ReferralProgramSubTypeID = @ReferralProgramSubTypeID
  WHERE OffenderID = @iOffenderID
END
GO

GRANT EXECUTE ON [dbo].[spTPalV2_Ofn_QuickAddSave] TO [db_dml];
GO
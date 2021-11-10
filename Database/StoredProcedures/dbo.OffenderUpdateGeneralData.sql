USE [TrackerPal]
GO

/****** Object:  StoredProcedure [dbo].[OffenderUpdateGeneralData]    Script Date: 08/04/2016 11:44:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* ******************************************************
 *   FileName:    OffenderUpdateGeneralData.sql
 *   Created On:  Unknown
 *   Created By:  Unknown
 *   Task #:      
 *   Purpose:     
 *   
 *   Modified By:  S.Abbasi 11/15/2010 - Added ReferralProgramID
 *                 R.Cole 11/16/2010 - Added IF EXISTS and
 *                  Grant STMTS.
 *				   SABBASI 02/17/2012  Added ReferralProgramSubTypeID 
 *                param field with reference  to Task #3055 
 *			      S.KHALIQ	04/18/2015 ADDED ReferralProgramSubTypeOptionID PARAM FIELD WITH REFERNCE TO TASK # 6496
 *			      H.Salahuddin 08/03/2016 Task #10592 Added ReferredFromID in update clause.
 * **************************************************** */
CREATE PROCEDURE [dbo].[OffenderUpdateGeneralData] (
	@OffenderID INT,
	@SalutationID INT = NULL,
	@FirstName NVARCHAR(50) = NULL,
	@MiddleName NVARCHAR(50) = NULL,
	@LastName NVARCHAR(50) = NULL,
	@SuffixID INT = NULL,
	@Alias1 NVARCHAR(50) = NULL,
	@Alias2 NVARCHAR(50) = NULL,
	@Alias3 NVARCHAR(50) = NULL,
	@TrackerDeviceID INT = NULL,
	@OffenderNumber NVARCHAR(25) = NULL,
	@CaseNumber NVARCHAR(25) = NULL,
	@FBINumber NVARCHAR(50) = NULL,
	@SSN NVARCHAR(11) = NULL,
	@RiskLevelID INT = NULL,
	@OffenseTypeID INT = NULL,
	@SentencingDurationStartDate DATETIME = NULL,
	@SentencingDurationEndDate DATETIME = NULL,
	@TrackingDurationStartDate DATETIME = NULL,
	@TrackingDurationEndDate DATETIME = NULL,
	@ModifiedByID INT = 0,
	@OffenseSubTypeId INT = 0,
	@HighProfileOffender BIT = 0,
	@ReferralProgramID INT,
	@ReferralProgramSubTypeID INT,
	@ReferralProgramSubTypeOptionID INT,
	@ReferredFromID INT
)
AS
BEGIN
  UPDATE [dbo].[Offender] 
    SET SalutationID = @SalutationID,
	      FirstName = @FirstName,
	      MiddleName = @MiddleName,
	      LastName = @LastName,
	      SuffixID = @SuffixID,
	      Alias1 = @Alias1,
	      Alias2 = @Alias2,
	      Alias3 = @Alias3,
	      TrackerID = @TrackerDeviceID,
	      OffenderNumber = @OffenderNumber,
	      CaseNumber = @CaseNumber,
	      FBINumber = @FBINumber,
	      SSN = @SSN,
	      RiskLevelID = @RiskLevelID,
	      OffenseTypeID = @OffenseTypeID,
	      SentencingDurationStartDate = @SentencingDurationStartDate,
	      SentencingDurationEndDate = @SentencingDurationEndDate,
	      TrackingDurationStartDate = @TrackingDurationStartDate,
	      TrackingDurationEndDate = @TrackingDurationEndDate,
	      OffenseSubTypeID = @OffenseSubTypeID,
	      HighProfileOffender = @HighProfileOffender,
	      ReferralProgramID = @ReferralProgramID,
		  ReferralProgramSubTypeID = @ReferralProgramSubTypeID,
		  ReferralProgramSubTypeOptionID=@ReferralProgramSubTypeOptionID,
		  ReferredFromID = @ReferredFromID
  WHERE OffenderID = @OffenderID
END

GO


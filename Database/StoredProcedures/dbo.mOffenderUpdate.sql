USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mOffenderUpdate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mOffenderUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   mOffenderUpdate.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc
 * Task #:     Redmine #      
 * Purpose:    Update an offender record               
 *
 * Modified By: Sohail - 8/15/2013: Per 3752, added 
 *      PoliceDistrictID. 
 * ******************************************************** */
CREATE PROCEDURE [mOffenderUpdate] (
	@OffenderID int,
	@ModifiedByID int,
	@AgencyID int,
	@OfficerID int,
	@FirstName NVARCHAR(50),
	@MiddleName NVARCHAR(50) = NULL,
	@LastName NVARCHAR(50),
	@BirthDate DATETIME,
	@RiskLevelID int,
	@OffenderPay bit,
  @PoliceDistrictID INT = NULL
)
AS
BEGIN
  IF @OfficerID NOT IN (SELECT OfficerID FROM Offender_Officer WHERE OffenderID = @OffenderID)
    BEGIN
      UPDATE Offender_Officer
        SET	OfficerID = @OfficerID
        WHERE OffenderID = @OffenderID

    END 

  UPDATE Offender
    SET ModifiedDate = GETDATE(),
	      ModifiedByID = @ModifiedByID,
	      AgencyID = @AgencyID,
	      FirstName = @FirstName,
	      MiddleName = @MiddleName,
	      LastName = @LastName,
	      BirthDate = @BirthDate,
	      RiskLevelID = @RiskLevelID,
	      OffenderPay=@OffenderPay,
 	      PoliceDistrictID=@PoliceDistrictID 
    WHERE OffenderID = @OffenderID
END
GO

GRANT EXECUTE ON [mOffenderUpdate] TO [db_dml]
GO

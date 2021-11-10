USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OffenderAdd]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OffenderAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi 
-- Create date: 05-Apr-2010
-- Description:	This procedure adds Offender info from Offender
-- Flex data capturing screen. The target version is TackerPAL Charlie (5.5.0)
-- =============================================
CREATE PROCEDURE [dbo].[OffenderAdd]
	@CreatedByID int,  
	@AgencyID int,  
	@OfficerID int,  
	@FirstName NVARCHAR(50),  
	@MiddleName NVARCHAR(50) = NULL,  
	@LastName NVARCHAR(50),   
	@OffenderID int OUTPUT,  
	@CaseNumber nvarchar(25) = null,
    @HomePhone1 NVARCHAR(25),
	@CellPhone1 NVARCHAR(25),-- This field is missing in DB
    @Alias1 NVARCHAR(25),
    -- Email -- No Field for Email.
    @EthnicityID int = Null,  
    @GenderID int = Null, -- Gender field is missing in DB. Rether Salutation
-- field is there. 
    @BirthDate datetime = Null,  
    @Height int = Null
	--@RiskLevelID int,  
	--@OffenderPay bit  
AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO [dbo].[Offender] (  
 [CreatedDate],  
 [CreatedByID],  
 [AgencyID],  
 [FirstName],  
 [MiddleName],  
 [LastName],  
 [BirthDate],  
 [Victim],
 [EthnicityID],
 [Height], 	  
 [Deleted]
)   
VALUES   
(  
 GETDATE(),  
 @CreatedByID,  
 @AgencyID,  
 @FirstName,  
 @MiddleName,  
 @LastName,  
 @BirthDate,  
 0,  
 @EthnicityID,
 @Height, 	  
 0  
 )  
  
SET @OffenderID = SCOPE_IDENTITY()  
  
IF @OfficerID IS NOT NULL  
BEGIN  
  
INSERT INTO [dbo].Offender_Officer (  
 [OffenderID],  
 [OfficerID]  
)  
VALUES  
(   
 @OffenderID,  
 @OfficerID  
)  
END  

	
END

GO

GRANT EXECUTE ON [dbo].[OffenderAdd] TO db_dml;
GO

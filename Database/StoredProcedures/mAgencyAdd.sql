USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[mAgencyAdd]    Script Date: 03/05/2015 12:26:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[mAgencyAdd]  
 @AgencyID INT OUTPUT,  
 @Agency NVARCHAR(50),  
 @StreetLine1 NVARCHAR(50),  
 @StreetLine2 NVARCHAR(50) = NULL,  
 @City NVARCHAR(50),  
 @StateID INT,  
 @PostalCode NVARCHAR(25),  
 @CountryID INT,  
 @Phone NVARCHAR(25),  
 @Fax NVARCHAR(25) = NULL,  
 @URL NVARCHAR(50) = NULL,  
 @EmailAddress NVARCHAR(50),  
 @CreatedByID INT,  
 @OnCallPhone NVARCHAR(50),  
 @OnCallPager NVARCHAR(50) = NULL,  
 @OnCallEmail NVARCHAR(50),  
 @TimeZoneID INT,  
 @DaylightSavings BIT,  
 @DistributorID INT = NULL,  
 @SMSAddress NVARCHAR(50) = NULL,  
 @SMSGatewayID INT = NULL,  
 @Autocall BIT,
 @GraceEarly INT =0,
 @GraceLate INT = 0,
 @GraceEnable BIT = 0,
 @HealCount INT,
 @SFDCAccount NVARCHAR(50)=NULL
 
  
AS  
BEGIN
 INSERT INTO Agency  
 (Agency, StreetLine1, StreetLine2, City, StateID, PostalCode,   
  CountryID, Phone, Fax, URL, EmailAddress, CreatedByID,   
  OnCallPhone, OnCallPager, OnCallEmail, TimeZoneID, DaylightSavings, 
  DistributorID,SMSAddress,SMSGatewayID, GraceEarly , GraceLate,GraceEnable,HealCount,SFDCAccount)  
 VALUES  
 (@Agency, @StreetLine1, @StreetLine2, @City, @StateID, @PostalCode,   
  @CountryID, @Phone, @Fax, @URL, @EmailAddress, @CreatedByID,  
  @OnCallPhone, @OnCallPager, @OnCallEmail, @TimeZoneID, @DaylightSavings, 
  @DistributorID,@SMSAddress,@SMSGatewayID, @GraceEarly,@GraceLate, @GraceEnable,@HealCount,@SFDCAccount)  
  
 SET @AgencyID = @@IDENTITY  

IF @Autocall = 1
	BEGIN
	INSERT INTO AgencyProtocolActionsAllowed  
	(AgencyID, AlarmProtocolActionListID)  
	VALUES  
	(@AgencyID, 8)
	END

END




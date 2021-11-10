USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_guest_AddVerificationKey]    Script Date: 08/08/2014 11:21:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_guest_AddVerificationKey.sql
 * Created On: 8-Mar-2014         
 * Created By: Sohail
 * Task #:     5520
 * Purpose:    Inserts new guest verification key in the database.
 *
 * Modified: R.Cole - 4/21/2014: Renamed CreationDate to CreatedDate
 *           and ExpiryDate to ExpirationDate
 *           Sohail-26 Apr 2014:Added New field UserID Task # 5993 Comment # 19
 *           Sohail-8 Auguest 2014:Added two new fields alarmID,email as per Task # 6383
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_guest_AddVerificationKey] (
  @VerificationKey NVARCHAR(100),
	@CreatedDate DATETIME,
	@IsValid BIT,
	@ExpirationDate DATETIME,
	@UserID INT,
	@AlarmID INT,
	@EmailAddress NVARCHAR(100)
)	 
AS
INSERT INTO GuestVerification (
	VerificationKey,
	CreatedDate,
	IsValid,
	ExpirationDate,
	UserID,
	AlarmID,
	Email
	
) 
VALUES (
	@VerificationKey,
	@CreatedDate,
	@IsValid,
	@ExpirationDate,
	@UserID,
	@AlarmID,
	@EmailAddress
)

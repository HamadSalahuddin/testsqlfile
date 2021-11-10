set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/* **********************************************************
 * FileName:   spTPal_guest_ValidateVerificationKey.sql
 * Created On: 7-Mar-2014         
 * Created By: Sohail
 * Task #:     5520
 * Purpose:    Checks if guest verification key is valid or not
 *
 * Modified By: R.Cole - 4/21/2014: Renamed ID to GuestVerificationID
 *              Changed all references of ExpiryDate to ExpirationDate
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_guest_ValidateVerificationKey] (
  @GuestVerificationID BIGINT OUTPUT,
	@VerificationKey NVARCHAR(100)
)	 
AS
  
--invalidating all the expired Verification Keys
UPDATE GuestVerification 
  SET IsValid = 'false' 
  WHERE ExpirationDate < GETDATE()

SET @GuestVerificationID = ISNULL((SELECT GuestVerificationID 
                                   FROM GuestVerification 
                                   WHERE VerificationKey = @VerificationKey 
                                     AND IsValid = 'true') ,0);



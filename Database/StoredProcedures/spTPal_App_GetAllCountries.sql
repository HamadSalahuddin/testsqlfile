USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_App_GetAllCountries]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_App_GetAllCountries]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_App_GetAllCountries.sql
 * Created On: 12-Nov-2010
 * Created By: Sajid Abbasi
 * Task #:     
 * Purpose:    Get all the countries and their properties.
 *
 * Modified By: R.Cole - 11/16/2010: #1613 - Added IF EXISTS
 *                and GRANT stmts.
 * ******************************************************** */
CREATE PROCEDURE spTPal_App_GetAllCountries 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT CountryID,
	       Country,
	       StateLabel,
	       PostalCodeLabel,
		     PostalCodeFormat,
		     PhoneNumberLabel,
		     PhoneNumberFormat,
		     SocialSecurityLabel,
		     SocialSecurityFormat,
		     DateLabel,
		     [DateFormat]
	FROM Country
END
GO

GRANT EXECUTE ON [dbo].[spTPal_App_GetAllCountries] TO db_dml
GO

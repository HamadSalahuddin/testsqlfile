USE [Trackerpal]
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_App_GetAllCounties]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_App_GetAllCounties]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_App_GetAllCounties.sql
 * Created On: 12-Nov-2010
 * Created By: Sajid Abbasi
 * Task #:     #1613
 * Purpose:    Get all the countries and their properties.               
 *
 * Modified By:  R.Cole - 11/12/2010: Added IF EXISTS and 
 *                GRANT stmts.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_App_GetAllCounties] 
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

GRANT EXECUTE ON [dbo].[spTPal_App_GetAllCounties] TO db_dml;
GO
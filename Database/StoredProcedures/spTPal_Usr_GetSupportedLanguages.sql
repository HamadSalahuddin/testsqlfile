USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Usr_GetSupportedLanguages]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Usr_GetSupportedLanguages]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Usr_GetSupportedLanguages.sql
 * Created On: 25-May-2011         
 * Created By: SABBASI  
 * Task #:     
 * Purpose:    Get list of all the languages for which localization
 *             support is added in TrackerPAL
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Usr_GetSupportedLanguages]
AS
BEGIN
  SELECT LanguageCode, 
         LanguageName 
	FROM LanguageSupported
END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Usr_GetSupportedLanguages] TO db_dml;
GO
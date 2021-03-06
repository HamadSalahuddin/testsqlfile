USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Usr_GetCultureInfo]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Usr_GetCultureInfo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Usr_GetCultureInfo.sql
 * Created On: 25-May-2011         
 * Created By: SABBASI  
 * Task #:     
 * Purpose:    Get Language Selected by user for localization
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Usr_GetCultureInfo] (
	@UserID INT
)
AS
BEGIN   
	SELECT [Language] 
	FROM UserPreferences
	WHERE UserID = @UserID
END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Usr_GetCultureInfo] TO db_dml;
GO

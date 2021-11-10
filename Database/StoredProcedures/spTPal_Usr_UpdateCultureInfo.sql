USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Usr_UpdateCultureInfo]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Usr_UpdateCultureInfo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Usr_UpdateCultureInfo.sql
 * Created On: 25-May-2011         
 * Created By: SABBASI  
 * Task #:     
 * Purpose:    Update culture info for localization               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Usr_UpdateCultureInfo] (
	@UserID INT,
	@Language VARCHAR(50)
)
AS
BEGIN
  UPDATE UserPreferences
	  SET [Language] = @Language
	  WHERE UserID = @UserID
END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Usr_UpdateCultureInfo] TO db_dml;
GO
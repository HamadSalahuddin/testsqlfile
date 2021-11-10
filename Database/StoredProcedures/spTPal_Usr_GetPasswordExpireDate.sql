USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Usr_GetPasswordExpireDate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Usr_GetPasswordExpireDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Usr_GetPasswordExpireDate.sql
 * Created On: 06/01/2012
 * Created By: R.Cole
 * Task #:     #3410
 * Purpose:    Retrieve the users password expiration date               
 *
 * Modified By: R.Cole - 06/04/2012: Changed to use UserName
 *                rather than UserID
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Usr_GetPasswordExpireDate] (
--  @UserID INT,
  @UserName NVARCHAR(25)
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT u.UserPassword,
       u.PasswordExpireDate
FROM [User] u
WHERE u.UserName LIKE @UserName
  AND u.Deleted = 0
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Usr_GetPasswordExpireDate] TO db_dml;
GO
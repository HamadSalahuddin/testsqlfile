USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UserLogin]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserLogin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UserLogin.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Handle User logins               
 *
 * Modified By: R.Cole - 6/7/2012: Brought up to standard,
 *    added code to handle audit logging of user logins.
 * ******************************************************** */
CREATE PROCEDURE [UserLogin] (
	@UserID INT OUTPUT,
	@UserTypeID	INT OUTPUT,
	@RoleID INT OUTPUT,
	@UserName	NVARCHAR(25),
	@UserPassword	NVARCHAR(50)
)	
AS
SET NOCOUNT ON;

SELECT @UserID = u.UserID,
			 @UserTypeID = u.UserTypeID,
			 @RoleID = ur.RoleID
FROM [User] u
  INNER JOIN User_Role ur ON u.UserID = ur.UserID
WHERE	UserName = @UserName 
  AND UserPassword = @UserPassword 
  AND Deleted = 0

-- // Log Activity // --
IF @@ROWCOUNT > 0
  BEGIN
		UPDATE [User]
		  SET	LastLoginDate = GETDATE()
		  WHERE	UserID = @UserID

    INSERT INTO [UserLoginHistory] ([UserID])
      VALUES (@UserID)
	END
GO

GRANT VIEW DEFINITION ON [UserLogin] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [UserLogin] TO [db_dml]
GO

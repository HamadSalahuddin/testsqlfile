USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UserUpdatePassword]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserUpdatePassword]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UserUpdatePassword.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     N/A
 * Purpose:    Update a Users password               
 *
 * Modified By: R.Cole - 6/14/2012: Added two optional params
 *     and logic to update additional fields based on presence
 *     of optional param data.
 *              R.Cole - 6/21/2012: Added code to add a 
 *                record to the Audit table
 * ******************************************************** */
CREATE PROCEDURE [dbo].[UserUpdatePassword] (
	@UserID	INT,
	@Password	NVARCHAR(50),
	@ModifiedByID	INT,
  @PasswordExpireDate DATETIME = NULL,
  @PasswordEmail NVARCHAR(50) = NULL
) 
AS
SET NOCOUNT ON;
  
-- // Main Query // --
IF ((@PasswordExpireDate IS NOT NULL) AND (@PasswordEmail IS NOT NULL))
  BEGIN
    UPDATE [User]
	    SET	UserPassword = @Password,
			    ModifiedDate = GETDATE(),
			    ModifiedByID = @ModifiedByID,
          PasswordExpireDate = @PasswordExpireDate,
          PasswordEmail = @PasswordEmail
	    WHERE	UserID = @UserID

    -- Add record to Audit table
    INSERT INTO UserDataChangeHistory (UserID, UserPassword, PasswordEmail, ModifiedByID)
      VALUES (@UserID, @Password, @PasswordEmail, @ModifiedByID)
  END
ELSE
  IF ((@PasswordExpireDate IS NOT NULL) AND (@PasswordEmail IS NULL))
    BEGIN
      UPDATE [User]
	      SET	UserPassword = @Password,
			      ModifiedDate = GETDATE(),
			      ModifiedByID = @ModifiedByID,
            PasswordExpireDate = @PasswordExpireDate
	      WHERE UserID = @UserID

      -- Add record to Audit table
      INSERT INTO UserDataChangeHistory (UserID, UserPassword, ModifiedByID)
        VALUES (@UserID, @Password, @ModifiedByID)
    END
ELSE 
  IF ((@PasswordExpireDate IS NULL) AND (@PasswordEmail IS NOT NULL))
    BEGIN
      UPDATE [User]
	      SET	UserPassword = @Password,
			      ModifiedDate = GETDATE(),
			      ModifiedByID = @ModifiedByID,
            PasswordEmail = @PasswordEmail
	      WHERE UserID = @UserID

      -- Add record to Audit table
      INSERT INTO UserDataChangeHistory (UserID, UserPassword, PasswordEmail, ModifiedByID)
        VALUES (@UserID, @Password, @PasswordEmail, @ModifiedByID)
    END
ELSE
  BEGIN
    UPDATE [User]
	    SET	UserPassword = @Password,
			    ModifiedDate = GETDATE(),
			    ModifiedByID = @ModifiedByID
	    WHERE	UserID = @UserID

    -- Add record to Audit table
    INSERT INTO UserDataChangeHistory (UserID, UserPassword, ModifiedByID)
      VALUES (@UserID, @Password, @ModifiedByID)
  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[UserUpdatePassword] TO db_dml;
GO

GRANT VIEW DEFINITION ON [UserUpdatePassword] TO [db_object_def_viewers]
GO
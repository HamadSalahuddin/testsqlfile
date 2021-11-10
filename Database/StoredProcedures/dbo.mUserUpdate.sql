USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mUserUpdate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mUserUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   mUserUpdate.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Update a user record               
 *
 * Modified By: R.Cole - 6/21/2012: Brought up to standard,
 *                added code to insert a record in the audit
 *                table.  Set PasswordExpireDate if the
 *                UserPassword has been changed.
 * ******************************************************** */
CREATE PROCEDURE [mUserUpdate] (  
  @UserID INT,  
  @UserName NVARCHAR(25),  
  @UserPassword NVARCHAR(50) = NULL,    
  @ModifiedByID INT,    
  @UserPassCode NVARCHAR(50),
  @RoleID INT
)    
AS    
SET NOCOUNT ON;
 
BEGIN
  IF @UserPassword IS NULL
    BEGIN
      UPDATE [User]
        SET	UserName = @UserName,
	          ModifiedDate = GETDATE(),
	          ModifiedByID = @ModifiedByID,
	          UserPassCode = @UserPassCode
        WHERE	UserID = @UserID

      -- Add record to Audit table
      INSERT INTO UserDataChangeHistory (
        UserID, 
        UserName, 
        UserPassCode, 
        ModifiedByID
      )
      VALUES  (
        @UserID, 
        @UserName, 
        @UserPassCode, 
        @ModifiedByID
      )
    END
  ELSE
    BEGIN
      UPDATE [User]
        SET UserName = @UserName,
            UserPassword = @UserPassword,
            ModifiedDate = GETDATE(),
            ModifiedByID = @ModifiedByID,
            UserPassCode = @UserPassCode,
            PasswordExpireDate = DATEADD(MONTH, 6, GETDATE())
        WHERE	UserID = @UserID

      -- Add record to Audit table
      INSERT INTO UserDataChangeHistory (
        UserID, 
        UserName, 
        UserPassword, 
        UserPassCode, 
        ModifiedByID
      )
      VALUES (
        @UserID, 
        @UserName, 
        @UserPassword, 
        @UserPassCode, 
        @ModifiedByID
      )
    END 

  UPDATE User_Role
    SET RoleID = @RoleID
    WHERE UserID = @UserID
END
GO

GRANT EXECUTE ON [mUserUpdate] TO [db_dml]
GO

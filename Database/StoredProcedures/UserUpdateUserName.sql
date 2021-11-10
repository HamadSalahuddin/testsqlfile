USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UserUpdateUserName]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserUpdateUserName]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UserUpdateUserName.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Update a username               
 *
 * Modified By: R.Cole - 6/21/2012: Brought up to standard,
 *                add code to insert a record in the Audit table
 * ******************************************************** */
CREATE PROCEDURE [UserUpdateUserName] (
  @UserID INT,
  @UserName NVARCHAR(25),
  @ModifiedByID INT
)
AS
SET NOCOUNT ON;

-- Verify UserName does not already exist
DECLARE @RecordCount INT
SELECT @RecordCount = COUNT (*)
FROM [User]
WHERE UserName = @UserName
  AND UserID <> @UserID

IF @RecordCount > 0
  BEGIN
    RAISERROR('User Name "%s" already taken.  Please choose another.', 16, 1, @UserName)
  END
ELSE
  BEGIN
    UPDATE [User]
      SET UserName = @UserName,
          ModifiedDate = GETDATE(),
          ModifiedByID = @ModifiedByID
      WHERE UserID = @UserID

    -- Add record to Audit table
    INSERT INTO UserDataChangeHistory (UserID, UserName, ModifiedByID)
      VALUES (@UserID, @UserName, @ModifiedByID)
END

GO
GRANT VIEW DEFINITION ON [UserUpdateUserName] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [UserUpdateUserName] TO [db_dml]
GO

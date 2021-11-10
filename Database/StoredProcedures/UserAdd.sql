USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UserAdd]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UserAdd.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Add a new user               
 *
 * Modified By: R.Cole - 06/20/2012: Updated to Standard, 
 *                added code to insert record into Audit table.
 * ******************************************************** */
CREATE PROCEDURE [UserAdd] (
	@UserID INT OUTPUT,
	@UserTypeID	INT,
	@UserName	NVARCHAR(25),
	@UserPassword	NVARCHAR(50),
	@CreatedByID INT,
	@UserPassCode	NVARCHAR(50)
)
AS
SET NOCOUNT ON;

-- // Verify UserName does not already exist // --
DECLARE	@RecordCount INT
SELECT @RecordCount = COUNT (*)
FROM [User]
WHERE	UserName = @UserName

-- // Main Query // --
IF @RecordCount > 0
	BEGIN
		RAISERROR('User Name "%s" already taken.  Please choose another.', 16, 1, @UserName)
	END
ELSE
	BEGIN
		INSERT INTO [User] (
      UserTypeID, 
      UserName, 
      UserPassword, 
      CreatedByID,
      UserPassCode
    )
		VALUES (
      @UserTypeID, 
      @UserName, 
      @UserPassword, 
      @CreatedByID,
      @UserPassCode
     )
		SET @UserID = @@IDENTITY

 	  IF @UserID > 0  
	    BEGIN
        -- Create UserDataChangeHistory record
        INSERT INTO UserDataChangeHistory (
          UserID, 
          UserTypeID, 
          UserName, 
          UserPassword, 
          UserPassCode, 
          ModifiedByID
        )
        VALUES (
          @UserID,
          @UserTypeID,
          @UserName,
          @UserPassword,
          @UserPassCode,
          @CreatedByID
        )
      END
	END
GO

GRANT EXECUTE ON [UserAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [UserAdd] TO [db_object_def_viewers]
GO

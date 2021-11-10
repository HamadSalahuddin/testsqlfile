USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UserUpdate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UserUpdate.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Update a user record               
 *
 * Modified By: R.Cole - 6/21/2012: Brought up to standard,
 *                added code to insert record in Audit table.
 * ******************************************************** */
CREATE PROCEDURE [UserUpdate] (
  @UserID INT,
	@UserName NVARCHAR(25),
	@UserPassword	NVARCHAR(50),
	@ModifiedByID	INT,
	@UserPassCode	NVARCHAR(50)
)
AS
SET NOCOUNT ON;

BEGIN
  UPDATE [User]
    SET UserName = @UserName,
				UserPassword = @UserPassword,
				ModifiedDate = GETDATE(),
				ModifiedByID = @ModifiedByID,
				UserPassCode	=	@UserPassCode
		WHERE	UserID = @UserID

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
GO

GRANT VIEW DEFINITION ON [UserUpdate] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [UserUpdate] TO [db_dml]
GO

USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UserUpdatePassCode]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserUpdatePassCode]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UserUpdatePassCode.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Update a users passcode            
 *
 * Modified By: R.Cole - 6/21/2012: Brought up to standard
 *                added code to insert record into audit table
 * ******************************************************** */
CREATE PROCEDURE [UserUpdatePassCode] (
	@UserID INT,
	@PassCode NVARCHAR(50),
	@ModifiedByID INT
)
AS
SET NOCOUNT ON;

UPDATE [User]
  SET UserPassCode = @PassCode,
			ModifiedDate = GETDATE(),
			ModifiedByID = @ModifiedByID
	WHERE	UserID = @UserID

-- Add record to Audit table
INSERT INTO UserDataChangeHistory (
  UserID, 
  UserPasscode, 
  ModifiedByID
)
VALUES (
  @UserID, 
  @PassCode, 
  @ModifiedByID
)
GO

GRANT EXECUTE ON [UserUpdatePassCode] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [UserUpdatePassCode] TO [db_object_def_viewers]
GO

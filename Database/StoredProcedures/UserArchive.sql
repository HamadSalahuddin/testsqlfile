USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UserArchive]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UserArchive]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UserArchive.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Archive a user               
 *
 * Modified By: R.Cole - 6/21/2012: Brought up to standard,
 *                added code to insert record into audit table
 * ******************************************************** */
CREATE PROCEDURE [UserArchive] (
	@UserID			INT,
	@ModifiedByID	INT,
	@ModifiedDate	DATETIME = NULL OUTPUT
)
AS
SET NOCOUNT ON;

SET @ModifiedDate = GETDATE()

UPDATE [User]
  SET ModifiedDate = @ModifiedDate,
		  ModifiedByID = @ModifiedByID,
		  Deleted = 1
  WHERE	UserID = @UserID

INSERT INTO [UserDataChangeHistory] (UserID, ModifiedByID, Deleted)
  VALUES (@UserID, @ModifiedByID, 1)
GO

GRANT VIEW DEFINITION ON [UserArchive] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [UserArchive] TO [db_dml]
GO

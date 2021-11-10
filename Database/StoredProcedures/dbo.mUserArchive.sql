USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mUserArchive]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mUserArchive]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   mUserArchive.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Archive a user               
 *
 * Modified By: R.Cole - 6/21/2012: Brought up to standard,
 *                added code to insert record into audit table
 * ******************************************************** */
CREATE PROCEDURE [mUserArchive] (
  @UserID   INT,  
  @ModifiedByID INT,  
  @ModifiedDate DATETIME = NULL OUTPUT
)  
AS  
SET NOCOUNT ON;
  
SET @ModifiedDate = GETDATE()  
  
UPDATE [User]  
  SET ModifiedDate = @ModifiedDate,  
      ModifiedByID = @ModifiedByID,  
      Deleted = 1  
   WHERE UserID = @UserID 	

INSERT INTO [UserDataChangeHistory] (UserID, ModifiedByID, Deleted)
  VALUES (@UserID, @ModifiedByID, 1)

GO

GRANT EXECUTE ON [mUserArchive] TO [db_dml]
GO

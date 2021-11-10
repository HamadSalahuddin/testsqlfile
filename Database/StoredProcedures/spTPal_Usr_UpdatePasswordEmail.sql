USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Usr_UpdatePasswordEmail]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Usr_UpdatePasswordEmail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Usr_UpdatePasswordEmail.sql
 * Created On: 6/14/2012         
 * Created By: R.Cole
 * Task #:     #3408
 * Purpose:    Update a users PasswordEmail               
 *
 * Modified By: R.Cole - 6/21/2012: Add code to insert record
 *                into audit table.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Usr_UpdatePasswordEmail] (
  @UserID INT,
  @PasswordEmail NVARCHAR(50)--,
--  @ModifiedByID INT 
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
UPDATE [User]
  SET PasswordEmail = @PasswordEmail
  WHERE UserID = @UserID

-- Add record to Audit table
INSERT INTO UserDataChangeHistory (UserID, PasswordEmail, ModifiedByID)
  VALUES (@UserID, @PasswordEmail, @UserID)
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Usr_UpdatePasswordEmail] TO db_dml;
GO
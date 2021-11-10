USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Usr_InsertSession]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Usr_InsertSession]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Usr_InsertSession.sql
 * Created On: 29-Feb-2012
 * Created By: Keith Griffiths
 * Task #:     #3024
 * Purpose:    Insert Trackerpal session data into the session 
 *             table for consumption by TrackerPalV2               
 *
  * Modified By: KGriffiths - 4/17/2012 Added check for the 
 *            existance of a record before inserting.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Usr_InsertSession] (
  @SessionName NVARCHAR(50),
  @UserID INT,
  @DistributorID INT,
  @AgencyID INT,
  @OfficerID INT,
  @RoleID INT,
  @CountryID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
IF NOT EXISTS (SELECT 1 FROM [Session] WHERE [SessionName] = @SessionName)
  BEGIN  
    INSERT INTO [Session] (
      SessionName,
      UserID,
      DistributorID,
      AgencyID,
      OfficerID,
      RoleID,
      CountryID 
    )
    VALUES (
      @SessionName,
      @UserID,
      @DistributorID,
      @AgencyID,
      @OfficerID,
      @RoleID,
      @CountryID
    ) 
END        
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Usr_InsertSession] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Alm_GetSuspensionCreator]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Alm_GetSuspensionCreator]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Alm_GetSuspensionCreator.sql
 * Created On: 3/7/2012        
 * Created By: R.Cole  
 * Task #:     #3017
 * Purpose:    Get the user name of an alarm suspension               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Alm_GetSuspensionCreator] (
  @UserID INT
) 
AS

-- // Handle UserRole // --
DECLARE @RoleID INT
SET @RoleID = (SELECT RoleID FROM User_Role WHERE UserID = @UserID)
   
-- // Main Query // --
IF @RoleID IN (6,20)          -- Distributor Personnel
  BEGIN
    SELECT FirstName + ' ' + LastName AS 'UserName'
    FROM DistributorEmployee
    WHERE UserID = @UserID
  END
ELSE 
  IF @RoleID IN (4,8,9)       -- MC/SecureAlert Personnel
    BEGIN
    -- // NEVER give out Operator names // --
      SELECT 'Monitoring Center' AS 'UserName'
      -- SELECT FirstName + ' ' LastName AS 'UserName'
      -- FROM Operator
      -- WHERE UserID = @UserID
    END
ELSE
  IF @RoleID IN (2,3,15)      -- Agency Personnel
    BEGIN
      SELECT FirstName + ' ' + LastName AS 'UserName'
      FROM Officer
      WHERE UserID = @UserID
    END
ELSE
  SELECT ' ' AS 'UserName'    -- Catchall case
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Alm_GetSuspensionCreator] TO db_dml;
GO
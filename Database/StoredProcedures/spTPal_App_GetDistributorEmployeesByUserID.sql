USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_App_GetDistributorEmployeesByUserID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_App_GetDistributorEmployeesByUserID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_App_GetDistributorEmployeesByUserID.sql
 * Created On: DateTime         
 * Created By: Developer  
 * Task #:     #3274
 * Purpose:    Return the Distributor Employees associated with a 
 *             given UserID               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_App_GetDistributorEmployeesByUserID] (
  @UserID INT
) 
AS
SET NOCOUNT ON;

DECLARE @DistributorID INT
   
-- // Get Distributor // --
SET @DistributorID = (SELECT DistributorID FROM DistributorEmployee WHERE UserID = @UserID)

-- // Main Query // --
SELECT DistributorEmployee.UserID,
       DistributorEmployee.LastName + ', ' + DistributorEmployee.FirstName AS 'Name'
FROM DistributorEmployee 
WHERE	DistributorEmployee.DistributorID = @DistributorID 
  AND DistributorEmployee.Deleted = 0
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_App_GetDistributorEmployeesByUserID] TO db_dml;
GO
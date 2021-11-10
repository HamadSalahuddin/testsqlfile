USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[DistributorEmployeeGetByUserID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DistributorEmployeeGetByUserID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   DistributorEmployeeGetByUserID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:                   
 *
 * Modified By: R.Cole - 6/19/2012: Revised to meet coding
 *                std and added PasswordEmail to the results.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[DistributorEmployeeGetByUserID] (	
	@UserID	INT
)
AS
SET NOCOUNT ON;

-- // Main Query // --
SELECT DistributorEmployee.DistributorEmployeeID,
       DistributorEmployee.UserID,
       DistributorEmployee.DistributorID,
       DistributorEmployee.Title,
       DistributorEmployee.Department,
       DistributorEmployee.SalutationID,
       DistributorEmployee.FirstName,
       DistributorEmployee.MiddleName,
       DistributorEmployee.LastName,
       DistributorEmployee.SuffixID,
       DistributorEmployee.StreetLine1,
       DistributorEmployee.StreetLine2,
       DistributorEmployee.City,
       DistributorEmployee.StateID,
       DistributorEmployee.PostalCode,
       DistributorEmployee.CountryID,
       DistributorEmployee.DayPhone,
       DistributorEmployee.EveningPhone,
       DistributorEmployee.MobilePhone,
       DistributorEmployee.Pager,
       DistributorEmployee.Fax,
       DistributorEmployee.EmailAddress,
       DistributorEmployee.CreatedDate,
       DistributorEmployee.CreatedByID,
       DistributorEmployee.ModifiedDate,
       DistributorEmployee.ModifiedByID,
       DistributorEmployee.Deleted,
       DistributorEmployee.ExtDayPhone,
       DistributorEmployee.ExtEveningPhone,
       DistributorEmployee.EmailAddress2,
       u.PasswordEmail
FROM DistributorEmployee
  INNER JOIN [User] u ON DistributorEmployee.UserID = u.UserID
WHERE	DistributorEmployee.UserID = @UserID 
  AND	DistributorEmployee.Deleted = 0
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[DistributorEmployeeGetByUserID] TO db_dml;
GO
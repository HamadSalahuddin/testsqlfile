USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OperatorGetByUserID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OperatorGetByUserID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   OperatorGetByUserID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:                   
 *
 * Modified By: R.Cole - 6/19/2012: Revised to meet coding
 *                std and added PasswordEmail to the results.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[OperatorGetByUserID] (	
	@UserID	INT
)
AS
SET NOCOUNT ON;

-- // Main Query // --
SELECT ISNULL(Operator.OperatorID, 0) AS 'OperatorID',
			 ISNULL(Operator.Title, '') AS 'Title',
			 ISNULL(Operator.Department, '') AS 'Department',
			 ISNULL(Operator.SalutationID, 0) AS 'SalutationID',
			 ISNULL(Operator.FirstName, '') AS 'FirstName',
			 ISNULL(Operator.MiddleName, '') AS 'MiddleName',
			 ISNULL(Operator.LastName, '') AS 'LastName',
			 ISNULL(Operator.SuffixID, 0) AS 'SuffixID',
			 ISNULL(Operator.StreetLine1, '') AS 'StreetLine1',
			 ISNULL(Operator.StreetLine2, '') AS 'StreetLine2',
			 ISNULL(Operator.City, '') AS 'City',
			 ISNULL(Operator.StateID, 1) AS 'StateID',
			 ISNULL(Operator.PostalCode,'') AS 'PostalCode',
			 ISNULL(Operator.CountryID, 1) AS 'CountryID',
			 ISNULL(Operator.DayPhone, '') AS 'DayPhone',
			 ISNULL(Operator.EveningPhone, '') AS 'EveningPhone',
			 ISNULL(Operator.MobilePhone, '') AS 'MobilePhone',
			 ISNULL(Operator.Fax, '') AS 'Fax',
			 ISNULL(Operator.EmailAddress1, '') AS 'EmailAddress1',
			 ISNULL(Operator.EmailAddress2, '') AS 'EmailAddress2',
			 ISNULL(Operator.Pager, '') AS 'Pager',
       u.PasswordEmail
FROM Operator 
  INNER JOIN [User] u ON Operator.UserID = u.UserID
WHERE	Operator.UserID = @UserID 
  AND Operator.Deleted = 0
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[OperatorGetByUserID] TO db_dml;
GO
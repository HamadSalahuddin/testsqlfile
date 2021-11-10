USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OfficerGetByUserID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OfficerGetByUserID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   OfficerGetByUserID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:                   
 *
 * Modified By: R.Cole - 6/19/2012: Revised to meet coding
 *                std and added PasswordEmail to the results.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[OfficerGetByUserID] (	
	@UserID	INT
)
AS
SET NOCOUNT ON;

-- // Main Query // --
SELECT ISNULL(Officer.OfficerID, 0) AS 'OfficerID',
			 ISNULL(Officer.AgencyID, 0) AS 'AgencyID',
			 ISNULL(Officer.Title, '') AS 'Title',
			 ISNULL(Officer.Department, '') AS 'Department',
			 ISNULL(Officer.SalutationID, 0) AS 'SalutationID',
			 ISNULL(Officer.FirstName, '') AS 'FirstName',
			 ISNULL(Officer.MiddleName, '') AS 'MiddleName',
			 ISNULL(Officer.LastName, '') AS 'LastName',
			 ISNULL(Officer.SuffixID, 0) AS 'SuffixID',
			 ISNULL(Officer.StreetLine1, '') AS 'StreetLine1',
			 ISNULL(Officer.StreetLine2, '') AS 'StreetLine2',
			 ISNULL(Officer.City, '') AS 'City',
			 ISNULL(Officer.StateID, 1) AS 'StateID',
			 ISNULL(Officer.PostalCode,'') AS 'PostalCode',
			 ISNULL(Officer.CountryID, 1) AS 'CountryID',
			 ISNULL(Officer.DayPhone, '') AS 'DayPhone',
			 ISNULL(Officer.EveningPhone, '') AS 'EveningPhone',
			 ISNULL(Officer.MobilePhone, '') AS 'MobilePhone',
			 ISNULL(Officer.Fax, '') AS 'Fax',
			 ISNULL(Officer.EmailAddress1, '') AS 'EmailAddress1',
			 ISNULL(Officer.EmailAddress2, '') AS 'EmailAddress2',
			 ISNULL(Officer.Pager, '') AS 'Pager',		
			 ISNULL(Officer.SMSAddress, '') AS 'SMSAddress',
			 ISNULL(Officer.SMSGatewayID, '0') AS 'SMSGatewayID',
       u.PasswordEmail
FROM Officer
  INNER JOIN [User] u ON Officer.UserID = u.UserID
WHERE	Officer.UserID = @UserID 
  AND Officer.Deleted = 0
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[OfficerGetByUserID] TO db_dml;
GO
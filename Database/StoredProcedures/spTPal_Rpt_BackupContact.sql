USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_BackupContacts]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_BackupContacts]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_BackupContacts.sql
 * Created On: 01/30/2012
 * Created By: R.Cole
 * Task #:     2892
 * Purpose:    Return dataset to Backup Contacts report               
 *
 * Modified By:  R.Cole - 3/5/2012: Added code to handle Distributors,
 *                and Application Admins.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_BackupContacts] (
  @AgencyID INT,
  @DistributorID INT = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Main Query // --
IF ((@DistributorID > 0) AND (@AgencyID = -1))
  BEGIN
    -- // Get Resultset for All Agencies belonging to Distributor // --
    SELECT Agency.Agency,       
           Officer.FirstName + ' ' + Officer.LastName AS [Officer],
           ISNULL(ContactBackup.Priority, 0) AS [Priority],
           ISNULL((o1.FirstName + ' ' + o1.Lastname),'None Assigned') AS [BackupContact],
           CASE WHEN ContactBackup.ContactPhone IN ('DayPhone', 'Day Phone', 'OfficePhone', 'Office Phone') THEN o1.DayPhone -- Account for data kludge...
                WHEN ContactBackup.ContactPhone IN ('EveningPhone', 'Evening Phone') THEN o1.EveningPhone
                WHEN ContactBackup.ContactPhone IN ('MobilePhone', 'Mobile Phone') THEN o1.MobilePhone
                ELSE ''
           END AS [ContactPhone],
           CASE WHEN ContactBackup.ContactEmail IN ('EmailAddress1', 'Email Address 1') THEN o1.EmailAddress1
                WHEN ContactBackup.ContactEmail IN ('EmailAddress2', 'Email Address 2') THEN o1.EmailAddress2
                ELSE ''
           END AS [ContactEmail]
    FROM Officer
      INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
      LEFT OUTER JOIN ContactBackup ON Officer.UserID = ContactBackup.UserID
      LEFT OUTER JOIN Officer o1 ON ContactBackup.ContactUserID = o1.UserID
      INNER JOIN [User] usr ON Officer.UserID = usr.UserID
    WHERE Agency.DistributorID = @DistributorID
      AND usr.UserTypeID = 2          -- Officer's Only
      AND Agency.Deleted = 0          -- Active Agencies Only
      AND Officer.Deleted = 0         -- Active Officers Only
    ORDER BY Agency.Agency,
             Officer.FirstName + ' ' + Officer.LastName,
             ContactBackup.Priority    
  END
ELSE
  BEGIN
    -- // Get Resultset for Single Agency // --  
    SELECT Agency.Agency,       
           Officer.FirstName + ' ' + Officer.LastName AS [Officer],
           ISNULL(ContactBackup.Priority, 0) AS [Priority],
           ISNULL((o1.FirstName + ' ' + o1.Lastname),'None Assigned') AS [BackupContact],
           CASE WHEN ContactBackup.ContactPhone IN ('DayPhone', 'Day Phone', 'OfficePhone', 'Office Phone') THEN o1.DayPhone -- Account for data kludge...
                WHEN ContactBackup.ContactPhone IN ('EveningPhone', 'Evening Phone') THEN o1.EveningPhone
                WHEN ContactBackup.ContactPhone IN ('MobilePhone', 'Mobile Phone') THEN o1.MobilePhone
                ELSE ''
           END AS [ContactPhone],
           CASE WHEN ContactBackup.ContactEmail IN ('EmailAddress1', 'Email Address 1') THEN o1.EmailAddress1
                WHEN ContactBackup.ContactEmail IN ('EmailAddress2', 'Email Address 2') THEN o1.EmailAddress2
                ELSE ''
           END AS [ContactEmail]
    FROM Officer
      INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
      LEFT OUTER JOIN ContactBackup ON Officer.UserID = ContactBackup.UserID
      LEFT OUTER JOIN Officer o1 ON ContactBackup.ContactUserID = o1.UserID
      INNER JOIN [User] usr ON Officer.UserID = usr.UserID
    WHERE Agency.AgencyID = @AgencyID
      AND usr.UserTypeID = 2          -- Officer's Only
      AND Officer.Deleted = 0         -- Active Officers Only
    ORDER BY Agency.Agency,
             Officer.FirstName + ' ' + Officer.LastName,
             ContactBackup.Priority
  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_BackupContacts] TO db_dml;
GO
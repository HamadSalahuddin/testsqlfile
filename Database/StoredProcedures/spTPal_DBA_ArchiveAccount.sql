USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_DBA_ArchiveAccount]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_DBA_ArchiveAccount]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_DBA_ArchiveAccount.sql
 * Created On: 11/03/2011
 * Created By: R.Cole
 * Task #:     Redmine #      
 * Purpose:    Automate the archiving of accounts in the
 *             TrackerPal database               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_DBA_ArchiveAccount] (
  @UserID INT,
  @OfficerID INT = NULL,
  @OperatorID INT = NULL,
  @DistributorEmployeeID INT = NULL,  
  @AgencyID INT = NULL,
  @DistributorID INT = NULL,
  @ArchiveDate DATETIME = NULL
) 
AS

DECLARE @ArchivedByID INT,
        @GatewayName VARCHAR(1024)

-- // Get Server and set ArchivedByID to the server specific SuperUser // --
SET @GatewayName = (SELECT PropertyValue FROM Gateway.dbo.GatewayProperties WHERE PropertyID = '2000')
IF @GatewayName IS NOT NULL
  BEGIN
    SET @ArchivedByID = (SELECT CASE WHEN @GatewayName LIKE '%Demo%' THEN 1
                                     WHEN @GatewayName LIKE '%Production%' THEN 55
                                END
                        )
  END

-- // Check Date // --
IF @ArchiveDate IS NULL
  SET @ArchiveDate = GETDATE()
   
-- // Archive Officer // --   
IF @OfficerID IS NOT NULL
  BEGIN
    UPDATE Officer
      SET Deleted = 1,
          ModifiedDate = @ArchiveDate,
          ModifiedByID = @ArchivedByID
    WHERE OfficerID = @OfficerID
  END
  
-- // Archive Operator // --
IF @OperatorID IS NOT NULL
  BEGIN
    UPDATE Operator
      SET Deleted = 1,
          ModifiedDate = @ArchiveDate,
          ModifiedByID = @ArchivedByID
    WHERE OperatorID = @OperatorID
  END

-- // Archive DistributorEmployee // --
IF @DistributorEmployeeID IS NOT NULL
  BEGIN
    UPDATE DistributorEmployee
      SET Deleted = 1,
          ModifiedDate = @ArchiveDate,
          ModifiedByID = @ArchivedByID
    WHERE DistributorEmployeeID = @DistributorEmployeeID
  END
  
-- // Archive Agency // --
IF @AgencyID IS NOT NULL
  BEGIN
    UPDATE Agency
      SET Deleted = 1,
          ModifiedDate = @ArchiveDate,
          ModifiedByID = @ArchivedByID
    WHERE AgencyID = @AgencyID
  END
  
-- // Archive Distributor // --
IF @DistributorID IS NOT NULL
  BEGIN
    UPDATE Distributor
      SET Deleted = 1,
          ModifiedDate = @ArchiveDate,
          ModifiedByID = @ArchivedByID
    WHERE DistributorID = @DistributorID    
  END
  
-- // Archive User // --
UPDATE [User]
  SET Deleted = 1,
      UserPassCode = 'Notify Supervisor',
      ModifiedDate = @ArchiveDate,
      ModifiedByID = @ArchivedByID
WHERE UserID = @UserID
GO
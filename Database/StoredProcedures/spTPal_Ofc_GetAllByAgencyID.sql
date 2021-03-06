USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofc_GetAllByAgencyID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofc_GetAllByAgencyID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- FileName:	spTPal_Ofc_GetAllByAgencyID.sql
-- Author:		Sajid Abbasi
-- Create date: 23-Apr-2010
-- Description:	Gets officers list for an agency or agencies selected. 

-- Modified By: R.Cole 12/29/2010: #1765 - Revised for speed
--              and added condition to only allow
--              supervision officers access to their 
--              own offenders.
--              R.Cole 12/29/2010: #1765 - Revised for speed
--              and added condition to only allow
--              supervision officers access to their 
--              own offenders.
--              Sajid Abbasi 03/24/2011 - Feature #1909. 
--              Need to filter out Officers that belong 
--              to Agency Assitant
--              R.Cole - 3/24/2011 - Couple minor 
--              changes prior to SVN commit.
-- =============================================
CREATE PROCEDURE [dbo].[spTPal_Ofc_GetAllByAgencyID] (
	@AgencyIDs	VARCHAR(MAX),
	@UserID INT
)
AS

-- // Get UserRole for the User (Sup. Officer = 15) // --
DECLARE @UserRole INT  
SET @UserRole = (SELECT RoleID FROM User_Role WHERE UserID = @UserID)

-- // Extract AgencyIDs into a temp table // --
SELECT [number]
INTO #tmpAgencyIDs
FROM GetTableFromListId(@AgencyIDs)

CREATE CLUSTERED INDEX #xpktmpAgency on #tmpAgencyIDs(number)

-- // Supervision Officer // --
IF @UserRole = 15
  BEGIN
    SELECT Officer.OfficerID,
           ISNULL(Officer.LastName + ', ', '') + ISNULL(Officer.FirstName, '') AS 'OfficerName',
           Officer.AgencyID
    FROM Officer 
    WHERE Officer.UserID = @UserID
      AND Officer.Deleted = 0 
    ORDER BY Officer.LastName,
             Officer.FirstName    
  END
ELSE
  -- // All non-Supervision Officers // --
  BEGIN
    SELECT Officer.OfficerID, 
		       ISNULL(Officer.LastName + ', ', '') + ISNULL(Officer.FirstName, '') AS 'OfficerName',
		       Officer.AgencyID
    FROM	Officer
      INNER JOIN #tmpAgencyIDs ta ON Officer.AgencyID = ta.[number]
   		INNER JOIN User_Role ur ON Officer.UserID = ur.UserID	  		 
    WHERE Officer.Deleted = 0 
      AND ur.RoleID <> 3          -- Exclude Agency Assistants from the result set.
    ORDER BY Officer.LastName, 
             Officer.FirstName	  
  END 
GO
	
GRANT EXECUTE ON [dbo].[spTPal_Ofc_GetAllByAgencyID] TO db_dml;
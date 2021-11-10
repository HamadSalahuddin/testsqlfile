USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AgencyGetAllDetailsByRoleRights]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AgencyGetAllDetailsByRoleRights]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Agn_GetByRights.sql
 * Created On: 04/20/2010         
 * Created By: S.Abbasi  
 * Task #:     ?      
 * Purpose:    Return Agency information to TrackerPAL based               
 *             on the User's Role/Rights
 *
 * Modified By: R.Cole - 04/22/2010
 * ******************************************************** */

CREATE PROCEDURE [dbo].[AgencyGetAllDetailsByRoleRights] (
  @AgencyID INT = -1, 
  @UserID INT = -1
)
AS

-- Declare variable according to rights.
DECLARE @ViewAllAgencies INT, 
        @ViewDistributorBasedAgency INT,
        @UserSpecificAgency INT, 
        @TAM INT

SET @ViewAllAgencies = 1
SET @ViewDistributorBasedAgency = 2
SET @UserSpecificAgency = 3
SET @TAM = 4;

-- Get list of all rights associated with roles assigned to the user
WITH UserRights AS
(
  SELECT DISTINCT RightID 
  FROM [Role_Rights] 
  WHERE ',' + (SELECT Roles FROM [User] WHERE UserID = @UserID) + ',' LIKE '%,' + CAST(RoleID AS VARCHAR(50)) + ',%'
)SELECT * INTO #tempT FROM  UserRights

-- Check if user has rights to view only agency he belongs to.
--IF EXISTS (SELECT 1 FROM #tempT WHERE RightID = @UserSpecificAgency) -- Likely faster than SELECT *
IF EXISTS ( SELECT 1 FROM #tempT WHERE RightID = @UserSpecificAgency )
	BEGIN
		SELECT AgencyID, 
		       Agency, 
		       t.Name as TimeZoneName, 
		       t.UtcOffset, 
		       t.DaylightUtcOffset
		FROM Agency a WITH (NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
	  WHERE a.Deleted = 0 
	    and AgencyID = @AgencyID
		ORDER BY Agency
	END
ELSE IF EXISTS( SELECT 1 FROM #tempT WHERE RightID = @ViewAllAgencies )
	BEGIN
		SELECT AgencyID, 
		       Agency, 
		       t.Name as TimeZoneName, 
		       t.UtcOffset, 
		       t.DaylightUtcOffset
		FROM Agency a(NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
	  WHERE	a.Deleted = 0
		ORDER BY Agency
	END
ELSE IF EXISTS ( SELECT 1 FROM #tempT WHERE RightID = @ViewDistributorBasedAgency ) 
	BEGIN
	  SELECT AgencyID, 
	         Agency, 
	         t.Name as TimeZoneName, 
	         t.UtcOffset, 
	         t.DaylightUtcOffset
		FROM Agency a WITH (NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
		  INNER JOIN DistributorEmployee de ON a.DistributorID = de.DistributorID 
		         AND de.UserID = @UserID
		WHERE	a.Deleted = 0
		ORDER BY Agency
	END
ELSE IF EXISTS ( SELECT 1 FROM #tempT WHERE RightID = @TAM )
	BEGIN
	  SELECT AgencyID, 
	         Agency, 
	         t.Name as TimeZoneName, 
	         t.UtcOffset, 
	         t.DaylightUtcOffset
		FROM Agency a WITH (NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
		  INNER JOIN Distributor d ON d.DistributorID = a.DistributorID 
		         AND d.TamID = @UserID 
    WHERE	a.Deleted = 0
		ORDER BY Agency
	END
--END IF

-- Clean-up
DROP TABLE #tempT

GO

GRANT EXECUTE ON [dbo].[AgencyGetAllDetailsByRoleRights] TO db_dml;
GO

USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Agn_GetDetailByRights]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Agn_GetDetailByRights]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sajid Abbasi>
-- Create date: <22-Apr-2010>
-- Description:	<Gets details for an agency or agencies based on user rights. >
-- =============================================
CREATE PROCEDURE [dbo].[spTPal_Agn_GetDetailByRights]
	(@AgencyID int=-1, @UserID int=-1)
WITH 
EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON;
-- Declare variable according to rights.
DECLARE @ViewAllAgencies INT, @ViewDistributorBasedAgency INT ,@UserSpecificAgency INT, @TAM INT
SET @ViewAllAgencies = 1
SET @ViewDistributorBasedAgency = 2
SET @UserSpecificAgency = 3
SET @TAM = 4;

-- Get list of all rights associated with roles assigned to the user
WITH UserRights AS
(
	SELECT RightID FROM Role_Rights WHERE RoleID  IN
	(
		SELECT  ur.RoleID
		FROM [User] INNER JOIN User_Role ur ON  ur.UserID = [User].UserID
		WHERE [User].UserID = @UserID
	)
)SELECT * INTO #tempT FROM  UserRights

-- Check if user has rights to view all agencies.
 IF EXISTS( SELECT 1 FROM #tempT WHERE RightID = @ViewAllAgencies )
	BEGIN
		SELECT AgencyID, 
		       Agency, 
		       t.Name as TimeZoneName, 
		       t.UtcOffset, 
		       t.DaylightUtcOffset,
		       GraceEarly,
		       GraceLate,
		       GraceEnable
		FROM Agency a(NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
	  WHERE	a.Deleted = 0
		ORDER BY Agency
	END
-- Check if user has rights to view agencies associated to him only.
ELSE IF EXISTS ( SELECT 1 FROM #tempT WHERE RightID = @ViewDistributorBasedAgency ) 
	BEGIN
	  SELECT AgencyID, 
	         Agency, 
	         t.Name as TimeZoneName, 
	         t.UtcOffset, 
	         t.DaylightUtcOffset,
		     GraceEarly,
		     GraceLate,
		     GraceEnable
		FROM Agency a WITH (NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
		  INNER JOIN DistributorEmployee de ON a.DistributorID = de.DistributorID 
		         AND de.UserID = @UserID
		WHERE	a.Deleted = 0
		ORDER BY Agency
	END
-- I have no idea what the @TAM right is? I am using it as legacy.
ELSE IF EXISTS ( SELECT 1 FROM #tempT WHERE RightID = @TAM )
	BEGIN
	  SELECT AgencyID, 
	         Agency, 
	         t.Name as TimeZoneName, 
	         t.UtcOffset, 
	         t.DaylightUtcOffset,
		     GraceEarly,
		     GraceLate,
		     GraceEnable
		FROM Agency a WITH (NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
		  INNER JOIN Distributor d ON d.DistributorID = a.DistributorID 
		         AND d.TamID = @UserID 
    WHERE	a.Deleted = 0
		ORDER BY Agency
	END
-- Check if user has rights to view only agency he belongs to. As per discussion with Keith we may not
-- need following condition. Need to double check that whether we can eliminate it from SP or can be used in future.
ELSE IF EXISTS ( SELECT 1 FROM #tempT WHERE RightID = @UserSpecificAgency )
	BEGIN
		SELECT a.AgencyID, 
		       a.Agency, 
		       t.Name as TimeZoneName, 
		       t.UtcOffset, 
		       t.DaylightUtcOffset,
		       GraceEarly,
		       GraceLate,
		       GraceEnable
		FROM Agency a WITH (NOLOCK)
		  INNER JOIN TimeZone t ON t.TimeZoneID = a.TimeZoneID
		  INNER JOIN [Officer]	 o  ON a.AgencyID = o.AgencyID
	  WHERE a.Deleted = 0 
		AND o.UserID = @UserID
	    
--AgencyID = @AgencyID
		ORDER BY Agency
	END
--END IF

-- Clean-up
DROP TABLE #tempT
-- Stored Procedure End
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Agn_GetDetailByRights] TO db_dml;
GO


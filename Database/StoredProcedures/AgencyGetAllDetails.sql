USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AgencyGetAllDetails]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AgencyGetAllDetails]
GO

/* **********************************************************
 * FileName:   [AgencyGetAllDetails].sql
 * Created On: Aculis, Inc.         
 * Created By: Unknown  
 * Task #:		 
 * Purpose:                   
 *
 * Modified By: R.Cole - 01/19/2010
 * ******************************************************** */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AgencyGetAllDetails] (
  @AgencyID INT = -1, 
  @RoleID INT = -1, 
  @UserID INT = -1
)
AS

-- // Agency Admin & Supervision Officer // --
IF @RoleID = 2 OR @RoleID = 15 
	BEGIN
		SELECT Agency.AgencyID, 
		       Agency.Agency, 
		       TimeZone.Name AS TimeZoneName, 
		       TimeZone.UtcOffset, 
		       TimeZone.DaylightUtcOffset
		FROM	Agency (NOLOCK)
		  INNER JOIN TimeZone ON TimeZone.TimeZoneID = Agency.TimeZoneID
	  WHERE	Agency.deleted = 0 
	    AND Agency.AgencyID = @AgencyID
		ORDER BY Agency.Agency
	END
-- // Application Admin & Operator // --
ELSE IF @RoleID = 8 OR @RoleID = 4
	BEGIN
		SELECT	Agency.AgencyID, 
		        Agency.Agency, 
		        TimeZone.Name AS TimeZoneName, 
		        TimeZone.UtcOffset, 
		        TimeZone.DaylightUtcOffset
		FROM Agency (NOLOCK)
		  INNER JOIN TimeZone ON TimeZone.TimeZoneID = Agency.TimeZoneID
	  WHERE	Agency.deleted = 0
		ORDER BY Agency.Agency
	END
-- // Distributor & Distributor Admin // --
ELSE IF @RoleID = 6 OR @RoleID = 20
	BEGIN
	  SELECT	Agency.AgencyID, 
	          Agency.Agency, 
	          TimeZone.Name as TimeZoneName, 
	          TimeZone.UtcOffset, 
	          TimeZone.DaylightUtcOffset
		FROM	Agency (NOLOCK)
		  INNER JOIN TimeZone ON TimeZone.TimeZoneID = Agency.TimeZoneID
		  inner join DistributorEmployee de on Agency.DistributorID = de.DistributorID 
		    and de.UserID = @UserID
		WHERE	Agency.deleted = 0
		ORDER BY Agency
	END
-- // TAM // --
ELSE IF @RoleID = 19
	BEGIN
	  SELECT	Agency.AgencyID, 
	          Agency.Agency, 
	          TimeZone.Name as TimeZoneName, 
	          TimeZone.UtcOffset, 
	          TimeZone.DaylightUtcOffset
		FROM Agency (NOLOCK)
		  INNER JOIN TimeZone ON TimeZone.TimeZoneID = Agency.TimeZoneID
		  inner join Distributor ON Distributor.DistributorID = Agency.DistributorID 
		    and Distributor.TamID = @UserID 
    WHERE	Agency.deleted = 0
		ORDER BY Agency.Agency
	END
ELSE
  -- // Others // --
	BEGIN
	  SELECT Agency.AgencyID, 
	         Agency.Agency, 
	         TimeZone.Name as TimeZoneName, 
	         TimeZone.UtcOffset, 
	         TimeZone.DaylightUtcOffset
		FROM	Agency (NOLOCK)
		  INNER JOIN TimeZone ON TimeZone.TimeZoneID = Agency.TimeZoneID
    WHERE	Agency.deleted = 0
		ORDER BY Agency.Agency
	END
GO

GRANT EXECUTE ON [dbo].[AgencyGetAllDetails] TO db_dml;
GO
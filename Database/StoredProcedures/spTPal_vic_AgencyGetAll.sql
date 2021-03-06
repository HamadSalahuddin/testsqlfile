USE [TrackerPal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- File Name: spTPal_vic_AgencyGetAll
-- Author:		SOHAIL
-- Create date: 27-Feb-2016
-- Description:	This procedure gets list of all Agency which has Victim Tab enabled.Task#8935

-- =============================================

CREATE PROCEDURE [dbo].[spTPal_vic_AgencyGetAll]
	@AgencyID	INT =-1,
	@RoleID		INT =-1,
	@UserID INT =-1

AS

IF @RoleID = 2 or @RoleID = 15 
	BEGIN
		SELECT	AgencyID, Agency 
		FROM	Agency (NOLOCK)
	 WHERE	deleted = 0 and
		AgencyID = @AgencyID and 
		EnableVictimTab=1
		ORDER BY Agency
	END
ELSE IF @RoleID = 8 or @RoleID = 4
	BEGIN
		SELECT	AgencyID, Agency 
		FROM	Agency (NOLOCK)
	 WHERE	deleted = 0 and 
		EnableVictimTab=1
		ORDER BY Agency
	END

ELSE IF @RoleID = 6 OR @RoleID = 20
	BEGIN
	SELECT	AgencyID, Agency 
		FROM	Agency a(NOLOCK)
		inner join distributoremployee de on a.DistributorID=de.DistributorID and de.UserID=@UserID
		 WHERE	a.deleted = 0 and 
		EnableVictimTab=1
		ORDER BY Agency
	END

ELSE IF @RoleID = 19
	BEGIN
	SELECT	AgencyID, Agency 
		FROM	Agency a(NOLOCK)
		inner join distributor d on d.DistributorID= a.DistributorID and d.TamID=@UserID 
WHERE	a.deleted = 0 and 
		EnableVictimTab=1
		ORDER BY Agency
	END

ELSE
	BEGIN
	SELECT	AgencyID, Agency 
		FROM	Agency a(NOLOCK)
WHERE	a.deleted = 0 and 
		EnableVictimTab=1
		ORDER BY Agency
	END

	
	

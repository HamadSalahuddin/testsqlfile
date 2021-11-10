USE TrackerPal
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Usr_GetACL]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Usr_GetACL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- File Name:	<spTPal_Usr_GetACL>
-- Author:		<Sajid Abbasi>
-- Create date: <30-Apr-2010>
-- Description:	<This procedure gets list of rights for a given user>
-- =============================================
CREATE PROCEDURE [dbo].[spTPal_Usr_GetACL]
	@UserID INT 
AS
BEGIN
	SET NOCOUNT ON;
	-- Get rights ID associated with 
    SELECT rr.RightID,r.RightName 
	FROM Role_Rights rr
	INNER JOIN Rights r ON r.RightID = rr.RightID
	WHERE rr.RoleID  IN
	(
		SELECT  ur.RoleID
		FROM [User] INNER JOIN User_Role ur ON  ur.UserID = [User].UserID
		WHERE [User].UserID = @UserID
	)
	
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Usr_GetACL] TO db_dml;
GO

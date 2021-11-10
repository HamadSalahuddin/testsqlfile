USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Usr_GetUserByUserTypeAndRole]    Script Date: 11/05/2015 06:13:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Usr_GetUserByUserTypeAndRole.sql
 * Created On: 11-Oct-2014
 * Created By: H.Salahuddin  
 * Task #:     7089
 * Purpose:    Get the List of User from MC i.e. User Type = 1 (Operator) & RoleID =8 (Operator) 
 * Modified By: H.Salahuddin 28th-Oct-2014. Added @UserTypeToFetch & @AgencyID parameters to fetch either Operators or Officers. If users are 
				Officers then these must be of specifici Agency. If want to fetch user of more than 1 Agency then User comma separated value for @AgencyID
				H.Salahuddin 5th-November-2015. Task#9233. Modified to sproc to support multiple agencies.				
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Usr_GetUserByUserTypeAndRole] 
	-- Add the parameters for the stored procedure here
	@UserTypeID INT ,
	@RoleID INT = NULL,
	@UserTypeToFetch INT,  -- 1 means Agency Users and 2 means Operators
	@AgencyID NVARCHAR (500)= NULL  -- use comma separated value if want to fetch user of multiple agencies
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF @UserTypeToFetch = 2 -- operators
Begin

Select U.UserID,UserName,R.RoleID,R.[Role]
From [TrackerPal].[dbo].[User] AS U
	 Inner Join [TrackerPal].[dbo].[User_Role] As UR On U.UserID= UR.UserID
	 Inner Join [TrackerPal].[dbo].[Role] As R	On R.RoleID= UR.RoleID And R.UserTypeID = U.UserTypeID
Where U.UserTypeID = @UserTypeID
And U.Deleted = 0 -- User is not deleted
And R.RoleID = @RoleID
Order By UserName

End

ELSE -- Agency Users
Begin

Select u.UserID,UserName
From Trackerpal.dbo.[User] u  
	 Inner Join Trackerpal.dbo.Officer o On u.UserID= o.UserID	 
Where o.AgencyID IN (Select number From Trackerpal.dbo.GetTableFromListId(@AgencyID)) 
And u.Deleted = 0 -- User is not deleted
And u.UserTypeID = @UserTypeID -- officers
Order by UserName
End -- IF @UserTypeToFetch

END

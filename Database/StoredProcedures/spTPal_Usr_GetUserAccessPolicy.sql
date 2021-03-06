USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Usr_GetUserAccessPolicy]    Script Date: 11/15/2014 11:39:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Usr_GetUserAccessPolicy.sql
 * Created On: 14-Oct-2014
 * Created By: H.Salahuddin  
 * Task #:     7089
 * Purpose:    Get the Access Policy of specific User 
 * Modified By: H.Salahuddin 22/Oct/2014 Added IsActivated field
			    H.Salahuddin 25/Oct/2014 Remove the ABS function on timezoneoffset. Also changed the expression to subtract instead of addition
			    so that it calculates the accurate time when local time is less than gmt.
			    also worked on UserAccessEndTime to check if it falls on next day.
			    H.salahuddin 25/Oct/2014. revert subtration from expression
			    H.salahuddin 15/Nov/2014. worked on UserStartTime to check if its greater than 24 hours for different time zone
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Usr_GetUserAccessPolicy] 
	-- Add the parameters for the stored procedure here
	@TimeZoneOffSet INT,
	@UserID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @UserAccessStartTime INT,
			@UserAccessStartTimeGT24 INT,
			@UserAccessEndTime INT,
			@UserAccessEndTimeGT24 INT
			
-- getting StartTime & EndTime in variables to assess if it falls in next day
Select @UserAccessStartTime= ((UserAccessStartTime + @TimeZoneOffSet)/60) ,
	   @UserAccessEndTime = ((UserAccessEndTime + @TimeZoneOffSet)/60)
							 From UserAccessPolicy
							 Where UserID =@UserID
							 
--UserAccessStartTime
IF @UserAccessStartTime >= 24 

BEGIN
	Set @UserAccessStartTimeGT24 = @UserAccessStartTime  - 24
END
ELSE
BEGIN
	Set @UserAccessStartTimeGT24 = @UserAccessStartTime
END
-- UserAccessEndTime							 
IF @UserAccessEndTime >= 24 

BEGIN
	Set @UserAccessEndTimeGT24 = @UserAccessEndTime  - 24
END
ELSE
BEGIN
	Set @UserAccessEndTimeGT24 = @UserAccessEndTime
END
		
    -- Insert statements for procedure here
	Select UserAccessPolicyID, UserID,@UserAccessStartTimeGT24 As UserAccessStartTime,
								  --(UserAccessStartTime + @TimeZoneOffSet)/60 AS UserAccessStartTime , 
								  (UserAccessStartTime + @TimeZoneOffSet) % 60 AS UserAccessStartTimeRem,
								  --(UserAccessEndTime + @TimeZoneOffSet)/60 AS UserAccessEndTime
								  @UserAccessEndTimeGT24 AS UserAccessEndTime,
                                  (UserAccessEndTime + @TimeZoneOffSet) % 60 As UserAccessEndTimeRem,
 UserAccessDays,(UserAccessDays & 1) As IsMondayOn, (UserAccessDays & 2) As IsTuesdayOn, (UserAccessDays & 4) As IsWednesdayOn,
 (UserAccessDays & 8) As IsThursdayOn, (UserAccessDays & 16) As IsFridayOn, (UserAccessDays & 32) As IsSaturdayOn, 
 (UserAccessDays & 64) As IsSundayOn ,@TimeZoneOffSet As TimeZoneOffSet,IsActivated
From UserAccessPolicy
Where UserID =@UserID
END

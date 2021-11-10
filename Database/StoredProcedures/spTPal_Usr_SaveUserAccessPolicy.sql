/* **********************************************************
 * FileName:   spTPal_Usr_SaveUserAccessPolicy.sql
 * Created On: 11-Oct-2014
 * Created By: H.Salahuddin  
 * Task #:     7089
 * Purpose:    Saves users access policy in db.
 * Modified By: 
 * ******************************************************** */
CREATE PROCEDURE spTPal_Usr_SaveUserAccessPolicy 
	-- Add the parameters for the stored procedure here
	@UserID INT,
	@UserAccessStartTime INT,
	@UserAccessEndTime INT,
	@UserAccessDays INT
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF Exists(Select 1
				From TrackerPal.Dbo.UserAccessPolicy
				Where UserID =@UserID)
		BEGIN
		
			UPDATE Trackerpal.Dbo.UserAccessPolicy
			SET UserAccessStartTime = @UserAccessStartTime ,
				UserAccessEndTime = @UserAccessEndTime ,
				UserAccessDays = @UserAccessDays
			WHERE UserID =@UserID			
		
		END 
	ELSE
		BEGIN
			INSERT INTO Trackerpal.Dbo.UserAccessPolicy(UserID,UserAccessStartTime,UserAccessEndTime,UserAccessDays)
			VALUES (@UserID ,@UserAccessStartTime ,	@UserAccessEndTime ,@UserAccessDays)
		END
		
END
GO

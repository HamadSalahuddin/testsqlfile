-- =============================================
-- FileName:	spTPal_Mob_UnregisterMobileDevice.sql
-- Author:		Hamad Salahuddin
-- Create date: 04/March/2015;
-- Task:		Task #7777 Access Apple Push Notification Feedback Service to identify bad devices
-- Description:	Delete the record from MobileUserRegistration table by RegistrationId
-- Modified By: 
-- =============================================
CREATE PROCEDURE spTPal_Mob_UnregisterMobileDevice 	
	@RegistrationId NVARCHAR(200),
	@Platform		NVARCHAR(50) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    If Exists (Select 1
			From Trackerpal.Dbo.MobileUserRegistration
			Where RegistrationId = @RegistrationId
			And [PLATFORM] = @Platform
		   )
	Begin
	Delete From TrackerPal.Dbo.MobileUserRegistration Where RegistrationId = @RegistrationId And [PLATFORM] = @Platform	
	End 
END
GO

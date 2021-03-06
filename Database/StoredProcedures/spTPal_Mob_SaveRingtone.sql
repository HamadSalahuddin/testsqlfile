USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Mob_SaveRingtone]    Script Date: 10/28/2014 17:38:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hamad Salahuddin
-- FileName		spTPal_Mob_SaveRingtone.sql
-- Create date: 23/Oct/2014
-- Description:	Task #7040 Add additional ringtones to settings. Updates or Insert record
-- Modified :   H.Salahuddin 25-Oct-2014 removed the RingtonID clause from Select 1 Statement
-- =============================================
ALTER PROCEDURE [dbo].[spTPal_Mob_SaveRingtone]
	-- Add the parameters for the stored procedure here
	@RegistrationId	NVARCHAR(2000),
	@EventTypeID	INT,
	@RingtoneID		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  IF Exists(Select 1
			From [TrackerPal].[Dbo].[DeviceRingtones]
			Where RegistrationId = @RegistrationId
			And EventTypeID = @EventTypeID)
	BEGIN
		-- COMMAND TO UPDATE THE RINGTONEID
		Update [TrackerPal].[Dbo].[DeviceRingtones]
		Set RingtoneID = @RingtoneID
		Where RegistrationId = @RegistrationId
		And EventTypeID = @EventTypeID
	END
	
	ELSE
	BEGIN
	-- COMMAND TO INSERT THE NEW RECORD
		Insert into [TrackerPal].[Dbo].[DeviceRingtones](RegistrationId,EventTypeID,RingtoneID)
		Values(@RegistrationId,@EventTypeID,@RingtoneID)
	END
	
	-- retrieving the record inserted or updated.
	
	Select DeviceRingtoneID,RegistrationId,EventTypeID,RingtoneID
			From [TrackerPal].[Dbo].[DeviceRingtones]
			Where RegistrationId = @RegistrationId
			And EventTypeID = @EventTypeID
			And RingtoneID = @RingtoneID 
END

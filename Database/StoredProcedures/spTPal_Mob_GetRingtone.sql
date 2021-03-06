USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Mob_GetRingtone]    Script Date: 10/31/2014 11:26:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hamad Salahuddin
-- FileName		spTPal_Mob_GetRingtone.sql
-- Create date: 23/Oct/2014
-- Description:	Task #7040 Add additional ringtones to settings. Get ringtone name by RegistrationId & EventTypeID
-- Modified :   H.Salahuddin 31/Oct/2014. Task#7040 Comment #9. Makde @EventTypeID optional.Added DeviceRingtoneID,
--				RegistrationId,et.EventTypeID,LongName as EventName,r.RingtoneID fields in SELECT clause
-- =============================================
ALTER PROCEDURE [dbo].[spTPal_Mob_GetRingtone] 
	-- Add the parameters for the stored procedure here
	@RegistrationId NVARCHAR(2000),
	@EventTypeID	INT = Null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here	
	
	Select DeviceRingtoneID,RegistrationId,et.EventTypeID,LongName as EventName,r.RingtoneID,Name
From Trackerpal.Dbo.Ringtones r 
	 Inner Join Trackerpal.Dbo.DeviceRingtones dr on r.RingtoneID = dr.RingtoneID
	 Inner Join Trackerpal.Dbo.EventType et on et.EventTypeID = dr.eventTypeID
Where RegistrationId =@RegistrationID
And  dr.EventTypeID =(ISNULL(@EventTypeID,dr.EventTypeID))
Order By EventTypeID
END

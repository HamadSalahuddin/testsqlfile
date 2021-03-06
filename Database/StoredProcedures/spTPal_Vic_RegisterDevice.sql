USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_RegisterDevice]    Script Date: 1/28/2020 10:14:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/* **********************************************************
 * FileName:   spTPal_Vic_RegisterDevice.sql
 * Created On: 01-FEB-2014
 * Created By: Hamad Salahuddin
 * Task #:		 N/A
 * Purpose:                   
 *
 * Modified By: Hamad Salahuddin 06-Feb-2014
			1.	if device is duplicated and unarchived then update the phone number
			2.	if device is found but archived then unarchived it and also update the phone number
 * SABBASI - 05/22/2014; Task #6089 ; Update device if it exists. Add new device if it does not exist
 *  or has been deleted.
 *  Sohail -- 17 Sep 2015 task#8763;added agencyID parameter
 *  Sohail -- 18 Dec 2015 Task 9131;removed update query.there is no need to update the record.
 *  H.Salahuddin 28/Jan/2020 Task #13617 Picked up recent most RegistrationID In case of re-registring Victim Device
 * ******************************************************** */
-- =============================================
ALTER PROCEDURE [dbo].[spTPal_Vic_RegisterDevice] 
	-- Add the parameters for the stored procedure here
	@DeviceIMEI  varchar(32),
	@DevicePhoneNumber varchar(32),
	@SMSGatewayID	   INT = 0,
	@AgencyID		   INT
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare
	@RegistrationID  Nvarchar(2000)
	BEGIN
	
	Select TOP 1 @RegistrationID = RegistrationID
	From Trackerpal.dbo.VictimDevice
	Where DeviceIMEI = @DeviceIMEI
	And Deleted = 1
	Order by VictimDeviceID desc
	
	INSERT INTO VictimDevice(VictimDeviceTypeID,DeviceIMEI,DevicePhoneNumber,SMSGatewayID,LastEventTime,NonCommAlarm,NoGPSAlarm,ProximityAlarm,Deleted,AgencyID,RegistrationID)
	 VALUES(2,@DeviceIMEI,@DevicePhoneNumber,@SMSGatewayID,GetDate(),0,0,0,0,@AgencyID,@RegistrationID)
		
	 return (3)
	END
END

/* **********************************************************
 * FileName:   spTPalV2_Vic_GetVictimDevicesForMoving.sql
 * Created On: 03/24/2020
 * Created By: H.Salahuddin
 * Task #:     13609
 * Purpose:    Get List of Victim Devices of an agency or specific IMEI for pointing to another server.               
 *
 * Modified By:
 * ******************************************************** */
CREATE PROCEDURE spTPalV2_Vic_GetVictimDevicesForMoving
@AgencyID INT = Null,
@CommaaSeparatedDeviceIMEIs NVARCHAR(2000) = Null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @AgencyID IS NOT NULL
	BEGIN 
		SELECT 
		   VictimDeviceID,
		   DeviceIMEI,
		   DevicePhoneNumber,
		   RegistrationID
		FROM TrackerPal.dbo.VictimDevice
		WHERE VictimDevice.Deleted = 0 
		AND AgencyID =@AgencyID
	END
	ELSE

		Select 
		   VictimDeviceID,
		   DeviceIMEI,
		   DevicePhoneNumber,
		   RegistrationID
	   
		From Trackerpal.dbo.VictimDevice
		WHERE VictimDevice.Deleted = 0			
			AND DeviceIMEI IN(Select Number From Trackerpal.[dbo].[GetTableStringFromListId](@CommaaSeparatedDeviceIMEIs))
END
GO

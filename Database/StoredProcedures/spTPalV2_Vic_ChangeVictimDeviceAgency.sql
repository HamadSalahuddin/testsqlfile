/* **********************************************************
 * FileName:   spTPalV2_Vic_ChangeVictimDeviceAgency.sql
 * Created On: 03/31/2021
 * Created By: R.Cole  
 * Task #:     14322
 * Purpose:    Update the Agency against the given victim device IMEI.              
 *
 * Modified By: 
 * ******************************************************** */
CREATE PROCEDURE spTPalV2_Vic_ChangeVictimDeviceAgency
	@DeviceIMEI NVARCHAR(32),
	@AgencyID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update TrackerPal.dbo.VictimDevice
	Set AgencyID = @AgencyID
	Where DeviceIMEI = @DeviceIMEI
END
GO
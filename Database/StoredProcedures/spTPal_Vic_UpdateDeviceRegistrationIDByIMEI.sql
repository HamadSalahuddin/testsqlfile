USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_UpdateDeviceRegistrationIDByIMEI]    Script Date: 08/11/2016 07:08:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Vic_UpdateDeviceRegistrationIDByIMEI.sql
 * Created On: 04/27/2016         
 * Created By: H.Salahuddin 
 * Task #: 8785    
 * Purpose:    Update Victim Device RegistrationID for GCM              
 *
 * Modified By: 			  
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Vic_UpdateDeviceRegistrationIDByIMEI] (
	@RegistrationID NVARCHAR(2000),
	@DeviceIMEI VARCHAR(32)
)
AS
BEGIN
	UPDATE Trackerpal.dbo.VictimDevice
	  SET RegistrationID = @RegistrationID
	  WHERE DeviceIMEI = @DeviceIMEI
	    AND Deleted = 0
	
	SELECT DeviceIMEI,
         RegistrationID
	FROM Trackerpal.dbo.VictimDevice
	WHERE DeviceIMEI = @DeviceIMEI
	  AND Deleted = 0
END

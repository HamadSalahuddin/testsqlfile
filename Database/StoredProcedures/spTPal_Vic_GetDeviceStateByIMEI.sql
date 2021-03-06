USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_GetDeviceStateByIMEI]    Script Date: 6/18/2021 3:03:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   spTPal_Vic_GetDeviceStateByIMEI.sql
 * Created On: 03/07/2012         
 * Created By: R.Cole 
 * Task #:     
 * Purpose:    Get Victim Device information               
 *
 * Modified By: R.Cole - 02/15/2013: Ported to TrackerPal
 * Modified By: SABBASI - 02/19/2013 - Added VictimDeviceTypeID,DevicePhoneNumber,DeviceIMEI and Deletde fields
 * in query result set.
 *             : SABBASI - 03/13/2013 - Added ProximityAlarm field in the result set.
 *			   : HamadSalahuddin -12/27/2013- changed the name of the table back to VictimeDevice instead of VictimDevices
 *			   : SABBASI - 02/06/2014; Added LastReceivedTime field in the result set.
 *			   :SABBASI - 05/22/2014; Task #6089 ; Added Deleted flag in the where condition
 *			   : H.Salahuddin 05/04/2016 Task #9802 Added RegistrationID  in the resultset
 *             : H.Salahuddin 06/18/2021 TPL-529 Added VictimID and OffenderID in the result set. 
* ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Vic_GetDeviceStateByIMEI] (
  @DeviceIMEI VARCHAR(32)
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Main Query // --
SELECT VictimDevice.VictimDeviceID,
	   VictimDeviceTypeID,
       DevicePhoneNumber,
	   DeviceIMEI,
       LastEventTime,
	   LastReceivedTime,
       NonCommAlarm,
       NoGPSAlarm,
       ProximityAlarm,
       VictimDevice.Deleted,
       RegistrationID,
	   ShutdownAlarm,
	   VictimID,
	   AssociatedOffenderID     
FROM VictimDevice
LEFT OUTER JOIN Victim on VictimDevice.VictimDeviceID = Victim.VictimDeviceID
WHERE DeviceIMEI = @DeviceIMEI 
AND VictimDevice.Deleted = 0
And IsNull(Victim.Deleted,0) = 0


USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_UpdateDeviceStateByIMEI]    Script Date: 02/06/2014 16:54:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Vic_UpdateDeviceStateByIMEI.sql
 * Created On: 03/07/2012         
 * Created By: R.Cole 
 * Task #:     
 * Purpose:    Update Victim Device information               
 *
 * Modified By: R.Cole - 02/15/2013: Ported to TrackerPal
 *			  : SABBASI - 03/13/2013: Added @ProximityAlarm field.
 *			  : SABBASI - 02/06/2014: Added @LastReceivedTime field in the update list.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Vic_UpdateDeviceStateByIMEI] (
  @DeviceIMEI VARCHAR(32),
  @LastEventTime DATETIME,
  @LastReceivedTime DATETIME,
  @NonCommAlarm BIT,
  @NoGPSAlarm BIT,
  @ProximityAlarm BIT
) 
AS
   
-- // Main Query // --
UPDATE VictimDevice
  SET LastEventTime = @LastEventTime,
	  LastReceivedTime = @LastReceivedTime,
      NonCommAlarm = @NonCommAlarm,
      NoGPSAlarm = @NoGPSAlarm,
	  ProximityAlarm = @ProximityAlarm
WHERE DeviceIMEI = @DeviceIMEI

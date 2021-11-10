USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPalV2_Vic_GetDevices]    Script Date: 03/24/2016 12:31:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPalV2_Vic_GetDevices.sql
 * Created On: 01/25/2013
 * Created By: R.Cole
 * Task #:     3886
 * Purpose:    Populate the Victim Device dropdown on the 
 *             VictimInfo screen with available devices               
 *
 * Modified By: R.Cole - 02/19/2013: Refactored to match new
 *              victim data model.
 * SABBASI - 05/22/2014; Task #6089 ; Added Deleted flag to filter out deletde records.
 :Sahib Zar Khan - 09/02/2015			   
			    Added VictimDevice.DevicePhoneNumber in the select query for Task #876
 * Sohail - 18 sep 2015;Task #8763;added AgencyID paramter and included it in the where cluase
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPalV2_Vic_GetDevices] (
@AgencyID INT
)
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT DISTINCT VictimDeviceID,
       DeviceIMEI,DevicePhoneNumber
FROM TrackerPal.dbo.VictimDevice
WHERE VictimDevice.Deleted = 0 AND AgencyID =@AgencyID
  AND VictimDeviceID NOT IN (SELECT VictimDeviceID FROM TrackerPal.dbo.VictimDevice_Tracker WHERE Deleted = 0)

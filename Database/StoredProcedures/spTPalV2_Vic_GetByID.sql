USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPalV2_Vic_GetByID]    Script Date: 03/24/2016 06:52:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPalV2_Vic_GetByID.sql
 * Created On: 01/29/2013
 * Created By: R.Cole
 * Task #:     3886
 * Purpose:    Load specific victim's data into the Victim 
 *             info screen               
 *
 * Modified By: R.Cole - 02/19/2013: Refactored to match new
 *              victim data model.
 *              R.Cole - 02/21/2013: Fixed an issue where the 
 *              VictimDeviceID was not being properly returned.
 *			   :Sahib Zar Khan - 06/27/2015
			   Handled newly Added New field Victim.Email to Victim Table Task 8441
			   :Sahib Zar Khan - 09/02/2015			   
			   Added VictimDevice.DevicePhoneNumber in select query for Task 8765
			   :Sahib Zar Khan - 09/03/2015			   
			   Added Victim.Comments in the select query for Task #8579
 *             Sohail: 5 Sep 2015; Task # 8569;Added new field ProxViolationDistanceUnit
 *			   Sahib:21 Sep 2015;Task #8763 added case statement for 0 Agency.FYI this 0 agency was due to a bug which is fixed in this ticket.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPalV2_Vic_GetByID] (
  @VictimID INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  
-- // Main Query // --
SELECT 
       [FirstName],
       [LastName],
       [GenderID],
       [BirthDate],
       [HomeStreet1],
       [HomeStreet2],
       [HomeCity],
       [HomeStateOrProvinceID],
       [HomeCountryID],
       [HomePostalCode],
       [Victim].[VictimDeviceID],[Victim].[Email],
       vdt.[TrackerID],
--       [AssociatedOffenderID],
--		   [VictimProxAlertDistance],       -- commented out for now
		   [Victim].[VictimProxViolationDistance],
		   [ProxViolationDistanceUnit],
   		   [HomePhone1TypeID],
		   [HomePhone2TypeID],
		   [HomePhone3TypeID],
		   [HomePhone1],
		   [HomePhone2],
		   [HomePhone3],
		   case  Victim.AgencyID
		   when 0 THEN
		   (SELECT AgencyID FROM Offender WHERE OffenderID = Victim.AssociatedOffenderID)
		   Else
		   Victim.AgencyID
		   End As 'AgencyID',
		   case Victim.OfficerID
		   when 0 THEN
		   (SELECT OfficerID FROM Offender_Officer WHERE OffenderID = Victim.AssociatedOffenderID)
		   Else
		   OfficerID
		   END As 'OfficerID',
       --For Task #8579
	   [Comments],
       VictimDevice.[DeviceIMEI],
        --For task 8765
       VictimDevice.[DevicePhoneNumber]		
FROM Victim
  LEFT OUTER JOIN VictimDevice_Tracker vdt ON Victim.VictimDeviceID = vdt.VictimDeviceID
  INNER JOIN VictimDevice ON Victim.VictimDeviceID = VictimDevice.VictimDeviceID
WHERE Victim.Deleted = 0
  AND Victim.VictimID = @VictimID

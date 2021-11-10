USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPalV2_Vic_Update]    Script Date: 03/24/2016 06:48:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPalV2_Vic_Update.sql
 * Created On: 01/28/2013
 * Created By: R.Cole  
 * Task #:     3886
 * Purpose:    Save an edit to a Victim record               
 *
 * Modified By: R.Cole - 01/29/2013: Added code to check the
 *              Offender_Officer table and updated if needed.
 *              R.Cole - 02/19/2013: Removed coded added in 
 *              previous comment.  Refactored to match new
 *              victim data model.
 *              R.Cole - 02/21/2013: Fixed a bug where the
 *              VictimDevice_Tracker insert was not executing
 *              properly.
 *				:SABBASI - 05/22/2014; Task #6089 ; Added Deleted flag in the where condition for getting TrackerID.
 *				SAHIB ZAR KHAN	- 06/27/2015 Added logic to Save Current datetime in a newly created field (CreatedDate) in 
 *											 VictimDevice_Tracker Table.
 *				:Sahib Zar Khan - 09/02/2015			   
			    Added VictimDevice.DevicePhoneNumber in the params and in update query for Task 8765
			    :Sahib Zar Khan - 09/03/2015			   
			    Added Victim.Comments in the params and in update query for Task #8579
 *              Sohail: 5 Sep 2015; Task # 8569;Added new field ProxViolationDistanceUnit
 *				Task # 8763;sohail 21 Sep 2015;OfficerID was passed as 0 from tpv2 victim detail screen
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPalV2_Vic_Update] (
  @VictimID INT,
  @AgencyID INT,
  @OfficerID INT,
  @FirstName NVARCHAR(50),
  @LastName NVARCHAR(50),
  @GenderID INT = NULL,  
  @BirthDate DATETIME = NULL,
  @Email	NVARCHAR(100) = NULL,
  @HomeStreet1 NVARCHAR(50) = NULL,
  @HomeStreet2 NVARCHAR(50) = NULL,
  @HomeCity NVARCHAR(50) = NULL,
  @HomeStateOrProvinceID INT = NULL,
  @HomeCountryID INT = NULL,
  @HomePostalCode NVARCHAR(25) = NULL,
  @VictimDeviceID INT,
  @HomePhone1TypeID INT = NULL,
  @HomePhone2TypeID INT = NULL,
  @HomePhone3TypeID INT = NULL,
  @HomePhone1 NVARCHAR(25) = NULL,
  @HomePhone2 NVARCHAR(25) = NULL,
  @HomePhone3 NVARCHAR(25) = NULL,
  @ModifiedByID INT,                             -- UserID of the user creating the record
  @OffenderTrackerID INT,
  @VictimProxViolationDistance FLOAT,
  @ProxViolationDistanceUnit INT,
--  @VictimProxAlertDistance INT = NULL         -- Not used is this iteration, we are only using the Violation distance
  @AssociatedOffenderID INT,
  --For Task #8765
  @DevicePhoneNumber nvarchar(25),
  --For Task #8579
  @Comments nvarchar(2000) = NULL
) 
AS
SET NOCOUNT ON;

DECLARE @TrackerID INT
--// Task # 8763;sohail 21 Sep 2015;OfficerID was passed as 0 from tpv2 victim detail screen
IF @OfficerID = 0
  BEGIN
    SET @OfficerID = (SELECT OfficerID FROM Offender_Officer WHERE OffenderID = @AssociatedOffenderID)
  END
-- // Update Victim data // --
UPDATE Victim
  SET FirstName = @FirstName,
      LastName = @LastName,
      GenderID = @GenderID,
      BirthDate = @BirthDate,
	  Email	    = @Email,
      HomeStreet1 = @HomeStreet1,
      HomeStreet2 = @HomeStreet2,
      HomeCity = @HomeCity,
      HomeStateOrProvinceID = @HomeStateOrProvinceID,
      HomeCountryID = @HomeCountryID,
      HomePostalCode = @HomePostalCode,
      VictimDeviceID = @VictimDeviceID,
      AssociatedOffenderID = @AssociatedOffenderID,
      --VictimProxAlertDistance = @VictimProxAlertDistance
      VictimProxViolationDistance = @VictimProxViolationDistance,
      ProxViolationDistanceUnit = @ProxViolationDistanceUnit,
      HomePhone1TypeID = @HomePhone1TypeID,
      HomePhone2TypeID = @HomePhone2TypeID,
      HomePhone3TypeID = @HomePhone3TypeID,
      HomePhone1 = @HomePhone1,
      HomePhone2 = @HomePhone2,
      HomePhone3 = @HomePhone3,
      ModifiedDate = GETDATE(),
      ModifiedByID = @ModifiedByID,
      AgencyID = @AgencyID,
      OfficerID = @OfficerID,
      Comments = @Comments     
WHERE VictimID = @VictimID

-- // Check for a change in Offender device // --
SET @TrackerID = (SELECT TrackerID FROM VictimDevice_Tracker WHERE VictimDeviceID = @VictimDeviceID AND Deleted = 0)

IF @TrackerID IS NULL
  BEGIN
    INSERT INTO VictimDevice_Tracker (
      [VictimDeviceID],
      [TrackerID], 
      [VictimProxAlertDistance], 
      [VictimProxViolationDistance], 
      [ProximityAlarm], 
      [LastEventTime],
	  [CreatedDate]
    )
    VALUES (
      @VictimDeviceID,
      @OffenderTrackerID,
      0,
      @VictimProxViolationDistance,
      0,
      GETDATE(),
	  GETDATE()
    )
  END
ELSE IF @OffenderTrackerID <> @TrackerID
  -- // Update VictimDevice_Tracker table // --
    BEGIN
      UPDATE VictimDevice_Tracker
        SET TrackerID = @OffenderTrackerID,
            VictimProxViolationDistance = @VictimProxViolationDistance,
			CreatedDate = GETDATE()
        WHERE VictimDeviceID = @VictimDeviceID
    END
ELSE
  BEGIN
    UPDATE VictimDevice_Tracker
      SET VictimProxViolationDistance = @VictimProxViolationDistance
      WHERE VictimDeviceID = @VictimDeviceID
  END
  --#Task 8765
  UPDATE VictimDevice Set DevicePhoneNumber =  @DevicePhoneNumber
  Where VictimDeviceID = @VictimDeviceID 

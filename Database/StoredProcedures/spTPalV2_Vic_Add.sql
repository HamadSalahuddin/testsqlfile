USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPalV2_Vic_Add]    Script Date: 03/24/2016 06:41:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPalV2_Vic_Add.sql
 * Created On: 01/28/2013
 * Created By: R.Cole
 * Task #:     3886
 * Purpose:    Create new Victim Record               
 *
 * Modified By: R.Cole - 02/19/2013: Refactored for new Victim
 *                data model.
 *				SAHIB ZAR KHAN	- 06/27/2015 Added logic to Save Current datetime in a newly created field (CreatedDate) in 
 *											 VictimDevice_Tracker Table.
				:Sahib Zar Khan - 09/02/2015			   
			    Added VictimDevice.DevicePhoneNumber in the params and in update query for Task #8765
			    :Sahib Zar Khan - 09/03/2015			   
			    Added Victim.Comments in the params and in update query for Task #8579
 *              Sohail: 5 Sep 2015; Task # 8569;Added new field ProxViolationDistanceUnit
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPalV2_Vic_Add] (
  @AgencyID INT,
  @OfficerID INT,
  @FirstName NVARCHAR(50),
  @LastName NVARCHAR(50),
  @GenderID INT = NULL,
  @BirthDate DATETIME = NULL,
  @Email	 NVARCHAR(100) = NULL,
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
  @CreatedByID INT,                             -- UserID of the user creating the record
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

-- // Account for empty params // --
IF @AgencyID = 0
  BEGIN
    SET @AgencyID = (SELECT AgencyID FROM Offender WHERE OffenderID = @AssociatedOffenderID)
  END

IF @OfficerID = 0
  BEGIN
    SET @OfficerID = (SELECT OfficerID FROM Offender_Officer WHERE OffenderID = @AssociatedOffenderID)
  END
   
-- // Main Query // --
INSERT INTO [dbo].[Victim] (
  [FirstName],
  [LastName],
  [GenderID],
  [BirthDate],
  [Email],
  [HomeStreet1],
  [HomeStreet2],
  [HomeCity],
  [HomeStateOrProvinceID],
  [HomeCountryID],
  [HomePostalCode],
  [VictimDeviceID],
  [AssociatedOffenderID],
  [VictimProxAlertDistance],
  [VictimProxViolationDistance],
  [ProxViolationDistanceUnit],
  [HomePhone1TypeID],
  [HomePhone2TypeID],
  [HomePhone3TypeID],
  [HomePhone1],
  [HomePhone2],
  [HomePhone3],
  [CreatedDate],
  [CreatedByID], 
  [AgencyID],
  [OfficerID],
  [Comments]
 
)
Values (
  @FirstName,
  @LastName,
  @GenderID,
  @BirthDate,
  @Email,
  @HomeStreet1,
  @HomeStreet2,
  @HomeCity,
  @HomeStateOrProvinceID,
  @HomeCountryID,
  @HomePostalCode,
  @VictimDeviceID,
  @AssociatedOffenderID,
  0,                            -- VictimProxAlertDistance
  @VictimProxViolationDistance,
  @ProxViolationDistanceUnit,
  @HomePhone1TypeID,
  @HomePhone2TypeID,
  @HomePhone3TypeID,
  @HomePhone1,
  @HomePhone2,
  @HomePhone3,
  GETDATE(),
  @CreatedByID,
  @AgencyID,
  @OfficerID,
  @Comments
)

-- // Update the VictimDevice_Device table in the Gateway // --
INSERT INTO TrackerPal.dbo.VictimDevice_Tracker (
  VictimDeviceID, 
  TrackerID, 
  VictimProxAlertDistance, 
  VictimProxViolationDistance,
  ProximityAlarm, 
  LastEventTime,
  CreatedDate
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

--#Task 8765
  UPDATE VictimDevice Set DevicePhoneNumber =  @DevicePhoneNumber
  Where VictimDeviceID = @VictimDeviceID 

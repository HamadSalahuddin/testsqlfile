USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPalV2_Vic_GetOffenderByAgencyID]    Script Date: 03/24/2016 12:34:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPalV2_Vic_GetOffenderByAgencyID.sql
 * Created On: 01/25/2013
 * Created By: R.Cole
 * Task #:     3886
 * Purpose:    Populate the VictimInfo screen in TrackerPal               
 *             with ACTIVE offenders
 * Modified By: R.Cole - 3/4/2014: modified to pull trackerid
 *             from offendertrackeractivation table rather than offender table
 *             Sohail;    18 Sep 2015;    task#8763; with introduction of agency drop down we dont need multiple if statements .
												     we just need agancy wise active offenders and in case of AgencyOfficer Role we need offenders
													 associated with that offier only.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPalV2_Vic_GetOffenderByAgencyID] (  
  @AgencyID INT,
  @OfficerID INT,
  @RoleID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
IF ((@AgencyID > 0) AND (@RoleID = 15))
  -- // Get Resultset for SecureAlert Users // --
  BEGIN
	 -- // Get Resultset for Single Agency, Single Officer // --
      SELECT Offender.OffenderID,
             ota.TrackerID,
--             Offender.TrackerID,
             Offender.LastName + ', ' + Offender.FirstName AS 'Offender'
      FROM Offender 
        INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
      WHERE Officer.OfficerID = @OfficerID
        AND TrackerActivationID = (SELECT MAX(TrackerActivationID)
                                   FROM OffenderTrackerActivation ta
                                   WHERE ta.OffenderID = Offender.OffenderID)
        AND ota.DeactivateDate IS NULL
        AND Offender.Deleted = 0
  END
ELSE
   BEGIN
     SELECT Offender.OffenderID,
       ota.TrackerID,
       Offender.LastName + ', ' + Offender.FirstName AS 'Offender'
FROM Offender
        INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID 
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
      WHERE Agency.AgencyID = @AgencyID 
        AND TrackerActivationID = (SELECT MAX(TrackerActivationID)
                                   FROM OffenderTrackerActivation ta
                                   WHERE ta.OffenderID = Offender.OffenderID)
        AND ota.DeactivateDate IS NULL
        AND Offender.Deleted = 0
         --Task 8264
      Order By Offender
   
    END

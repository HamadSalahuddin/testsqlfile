USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_ICU_GetTracks]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_ICU_GetTracks]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_ICU_GetTracks.sql
 * Created On: 3/9/2015
 * Created By: R.Cole
 * Task #:     Redmine #      
 * Purpose:    Get a list of offenders accessible to a given Officer's UserID               
 *
 * Modified By: R.Cole - 3/23/2015: Added code for DeactivateDate,
 *      Added DeviceModel and Provider
 *              R.Cole - 3/24/2015: Added code to account for a condition
 *      where the DeactivateDate could be earlier than the ActivateDate.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_ICU_GetTracks] (
  @UserID INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @UserIDLocal INT,
        @UserRoleID INT,
        @AgencyID INT,
        @OfficerID INT
        
-- // Deal with Param Sniffing // --
SET @UserIDLocal = @UserID        

-- // Get User Role // --
SET @UserRoleID = (SELECT RoleID FROM User_Role WHERE UserID = @UserIDLocal)

-- // Get Agency and OfficerID // --
SELECT @AgencyID = Agency.AgencyID,
		   @OfficerID = OfficerID
FROM Agency 
  INNER JOIN Officer ON Agency.AgencyID = Officer.AgencyID 
WHERE Officer.UserID = @UserIDLocal

-- // Main Query // --
SELECT aod.OffenderID AS [TrackID], 
       aod.LastName + ', ' + aod.FirstName AS [OffenderName], 
       NULL AS [Description],
       aod.Agency AS [FolderName],
       aod.ActivateDate AS [ActivateDate],
       (CASE WHEN dbo.ConvertLongToDate(gwDev.LastEventTime) > aod.ActivateDate THEN dbo.ConvertLongToDate(gwDev.LastEventTime)
             ELSE NULL -- aod.ActivateDate
       END) AS [DeactivateDate],                                              -- Should be the date of the most recent/current event (Fix)
--       dbo.ConvertLongToDate(gwDev.LastEventTime) AS [DeactivateDate],      -- Should be the date of the most recent/current event (Fix)
       GETDATE() AS [CurrentDate],  
       dp.PropertyValue AS [DeviceModel],                                   -- OTD S/N
       (CASE WHEN nop.[name] IS NULL	THEN nop1.[name] 
             ELSE (CASE	WHEN nop.[name] = 'AT&T' THEN (CASE WHEN dp2.PropertyValue >= 89014104212400000000 THEN 'AT&T - EOD' 
                                                            ELSE 'AT&T - Premier' END)
		                    ELSE nop.[name] END) 
       END) AS [Provider]                                                   -- Carrier
FROM vwTPal_ActiveOffendersDevices aod
  INNER JOIN Gateway.dbo.Devices gwDev ON aod.TrackerID = gwDev.DeviceID 
  INNER JOIN Gateway.dbo.DeviceProperties dp ON gwDev.DeviceID = dp.DeviceID AND dp.PropertyID = '8012'
	INNER JOIN Gateway.dbo.DeviceProperties dp2 ON gwDev.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8204' --ICCID 
	INNER JOIN Gateway.dbo.DeviceProperties dp3 ON gwDev.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202' --IMSI
	LEFT OUTER JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC + nop.MNC = LEFT(dp3.PropertyValue,6)
  LEFT OUTER JOIN Gateway.dbo.NetworkOperators nop1 ON nop1.MCC + nop1.MNC = LEFT(dp3.PropertyValue,5)		  
WHERE aod.AgencyID = @AgencyID
	AND aod.OfficerID = CASE WHEN @UserRoleID IN (2,3) THEN aod.OfficerID ELSE @OfficerID END  -- for types 2,3 get all Officers for Agency, otherwise just get the one Officer
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_ICU_GetTracks] TO db_dml;
GO
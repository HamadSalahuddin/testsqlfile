USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[BeaconGetAllDetailsByOffenderID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BeaconGetAllDetailsByOffenderID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   BeaconGetAllDetailsByOffenderID.sql
 * Created On: 1-Jan-2010         
 * Created By: Sajid Abbasi  
 * Task #:     Unknown     
 * Purpose:    Gets all the details about Beacon to 
 *             populate beacon object.               
 *
 * Modified By: R.Cole - 11/16/2010 - #1613 Added CountryID
 * ******************************************************** */
CREATE PROCEDURE [dbo].[BeaconGetAllDetailsByOffenderID] (
	 @OffenderID INT
)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT Beacon.ID as BeaconID, 
         Beacon.Identifier, 
         Beacon.BeaconName AS BeaconName,
         adr.ID,
         adr.Street1,
         adr.Street2,
         adr.ZipCode,
         adr.City,
         adr.StateID,
         adr.CountryID,
         GPSLocation.Longitude,
         GPSLocation.Latitude,			  
         ERule.ID as RuleID,
         ERule.Name AS RuleName,
         r.UploadStatusID, 	
		     r.FileID,
         Schedule.ID as ScheduleID,
         Schedule.StartDateTime, 
         Schedule.EndDateTime,
         Schedule.AlwaysOn, 
 	       ScheduleRepeatedDay.DayID   	       
  FROM dbo.BeaconOffender  
    INNER JOIN Beacon ON BeaconOffender.BeaconID = Beacon.ID 
    INNER JOIN ERule ON Beacon.ID = ERule.BeaconID 
    LEFT OUTER JOIN [Rule] r ON ERule.RuleID = r.ID 
    INNER JOIN [Address] adr ON Beacon.AddressID = adr.ID 
    INNER JOIN GPSLocation ON adr.ID = GPSLocation.ID 
    LEFT OUTER JOIN Schedule ON ERule.ID = Schedule.RuleID 
    LEFT OUTER JOIN ScheduleRepeatedDay ON Schedule.ID = ScheduleRepeatedDay.ScheduleID    
  WHERE BeaconOffender.OffenderID  = @OffenderID 
    AND Beacon.Deleted = 0
END
GO

GRANT EXECUTE ON [dbo].[BeaconGetAllDetailsByOffenderID] TO db_dml;
GO

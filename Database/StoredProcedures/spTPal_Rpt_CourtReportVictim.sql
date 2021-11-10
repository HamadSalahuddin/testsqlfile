USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Rpt_CourtReportVictim]    Script Date: 10/02/2015 07:12:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_CourtReportVictim.sql
 * Created On: 3/5/2014         
 * Created By: R.Cole
 * Task #:     #5737      
 * Purpose:    Add Victim data to CourtReport               
 *
 * Modified By: Sohail - 2 Oct 2015 --Task#8902; Location was set to Contant string "Unavailable".Changed it with Address Field of VictimEvents Table
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Rpt_CourtReportVictim] (
  @AgencyID INT,
  @OffenderID INT,
  @StartDate DATETIME,
  @EndDate DATETIME  
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
/*
DECLARE @AgencyID INT,
        @OffenderID INT,
        @StartDate DATETIME,
        @EndDate DATETIME

SET @AgencyID = 22
SET @OffenderID = 634 
SET @StartDate = '2014-03-04 00:00:00.001'
SET @EndDate = '2014-03-05 17:15:00.000'
*/

-- // Main Query // --
SELECT ISNULL(Victim.FirstName + ' ', '') + ISNULL(Victim.LastName, '') AS Offender,
       ISNULL(Officer.FirstName + ' ' , '') + ISNULL(Officer.LastName, '') AS Officer,
       ISNULL(Agency.Agency, '') AS Agency,
       VictimEvents.EventDisplayTime AS EventTime,
--       dbo.ConvertDateToLong(VictimEvents.EventDisplayTime) AS EventTime,  
       EventType.AbbrevEventType AS EventName, 
       NULL AS GeoRule,
       [Address] as Location,
       NULL AS AcceptedDate,
       NULL AS Operator,
       '' AS Notes,
	     ISNULL(ROUND(VictimEvents.Latitude,5), 0) AS 'Latitude',
	     ISNULL(ROUND(VictimEvents.Longitude,5), 0) AS 'Longitude',
	     1 AS 'GpsValid',
	     1 AS 'GpsValidSatellites',	
	     @StartDate AS 'StartDateAgency',
	     @EndDate AS 'EndDateAgency',
	     dbo.fnGetUtcOffset(@AgencyID) AS 'utcoffset',
       VictimEvents.EventTypeID AS EventID,
       Victim.VictimID AS OffenderID
FROM VictimEvents (NOLOCK)
  INNER JOIN Victim (NOLOCK) ON VictimEvents.VictimDeviceID = Victim.VictimDeviceID
  INNER JOIN EventType ON VictimEvents.EventTypeID = EventType.EventTypeID
  LEFT OUTER JOIN Agency ON Victim.AgencyID = Agency.AgencyID
  LEFT OUTER JOIN Officer ON Victim.OfficerID = Officer.OfficerID
WHERE EventDisplayTime >= @StartDate 
  AND EventDisplayTime <= @EndDate
  AND Victim.AssociatedOffenderID = @OffenderID 

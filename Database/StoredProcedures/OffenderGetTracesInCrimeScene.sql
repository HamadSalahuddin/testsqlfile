USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OffenderGetTracesInCrimeScene]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OffenderGetTracesInCrimeScene]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 03-Mar-2010
-- Description:	This procedure gets list of all event traces between given dates for
-- Offenders belonging to a specific ageny if that traces have been with the area of given radius.
-- modified on 19-Apr-2010 . To be able to accomodate changes in new charlie. We want to be able to get traces for
-- specified offender(s)
-- =============================================
CREATE PROCEDURE [dbo].[OffenderGetTracesInCrimeScene] (	
	@agencyID int,
	@StartDate DateTime,
	@EndDate DateTime,
	@CenterPointlat float,
	@CenterPointlong float,
	@radius float,
	@EventTypeID int,
	@OfficerID int = -1
)	 
AS
BEGIN
	SET NOCOUNT ON;
   
	WITH Events_CTE AS  
(  
    SELECT DeviceID,  
        TrackerNumber,  
        EventTime,  
        EventDateTime,  
        EventID,  
        AlarmType,  
        AlarmAssignmentStatusName,  
        Longitude,  
        Latitude,  
        [Address],  
        OffenderID,  
        AlarmID,  
        GpsValid,  
        GpsValidSatellites,  
        GeoRule,  
        SO,  
        OPR,  
        EventTypeGroupID,  
        OffenderName,  
        OffenderDeleted,
		OfficerID           
    FROM rprtEventsBucket2  
    WHERE EventDateTime BETWEEN @StartDate AND @EndDate   
      AND
   [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong,
   Latitude, Longitude) <= @radius 

   UNION  

    SELECT DeviceID,  
        TrackerNumber,  
        EventTime,  
        EventDateTime,  
        EventID,  
        AlarmType,  
        AlarmAssignmentStatusName,  
        Longitude,  
        Latitude,  
        [Address],  
        OffenderID,  
        AlarmID,  
        GpsValid,  
        GpsValidSatellites,  
        GeoRule,  
        SO,  
        OPR,  
        EventTypeGroupID,  
        OffenderName,  
        OffenderDeleted,
		OfficerID   
    FROM rprtEventsBucket1  
    WHERE EventDateTime BETWEEN @StartDate AND @EndDate   
AND
   [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong,
   Latitude, Longitude) <= @radius 
)SELECT * INTO #tmpEventTraces FROM Events_CTE  

----------- Fetch traces for all offenders that happen to come inside the area
SELECT	et.OffenderID,
		o.FirstName, o.LastName,
		o_o.OfficerID,
        et.DeviceID,  
        et.TrackerNumber,  
        et.EventTime,  
        et.EventDateTime,  
        et.EventID,  
        et.AlarmType,  
        et.AlarmAssignmentStatusName,  
        et.Longitude,  
        et.Latitude,  
        et.[Address],  
        et.AlarmID,  
        et.GpsValid,  
        et.GpsValidSatellites
		
FROM #tmpEventTraces et INNER JOIN Offender o
ON o.OffenderID = et.OffenderID INNER JOIN Agency a 
ON a.AgencyID = o.AgencyID INNER JOIN Offender_Officer o_o
ON o_o.OfficerID = et.OfficerID
	AND o.Deleted = 0
	AND a.AgencyID = @agencyID
AND 
( 
@OfficerID = -1
OR
o_o.OfficerID = @OfficerID
 
)
---- Drop temporary table ----
DROP Table #tmpEventTraces

END
GO

GRANT EXECUTE ON [dbo].[OffenderGetTracesInCrimeScene] TO db_dml;
GO

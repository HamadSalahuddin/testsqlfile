USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetTraces]    Script Date: 05/11/2010 12:46:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- File Name: spTPal_Ofn_GetTraces
-- Author:		Sajid Abbasi
-- Create date: 01-May-2010
-- Description:	This procedure gets list of all event traces between given dates for
-- given Offenders belonging to a specific agenies if that traces have been with the area of given radius.

-- =============================================
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetTraces]
	-- Add the parameters for the stored procedure here
	@AgencyIDs Varchar(MAX),
	@StartDate DateTime,
	@EndDate DateTime,
	@CenterPointlat float,
	@CenterPointlong float,
	@radius float,
	@EventTypeID int,
	@OfficerIDs Varchar(MAX), 
	@OffenderIDs Varchar(MAX)	
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
	WITH Events_CTE AS  
(  
    select DeviceID,  
        TrackerNumber,  
        EventTime,  
        EventDateTime,  
        EventID,
		EventName,  
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
(
@radius =0
OR
   [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong,
   Latitude, Longitude) <= @radius 
)
   UNION  

    SELECT DeviceID,  
        TrackerNumber,  
        EventTime,  
        EventDateTime,  
        EventID, 
		EventName, 
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
(
@radius =0
OR
   [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong,
   Latitude, Longitude) <= @radius 
)
)SELECT * INTO #tmpEventTraces FROM Events_CTE  

----------- Fetch traces for all offenders that happen to come inside the area
SELECT	et.OffenderID,
		o.LastName+','+ o.FirstName AS 'OffenderName',
		o_o.OfficerID,
        et.DeviceID,  
        et.TrackerNumber,  
        et.EventTime,  
        et.EventDateTime,  
        et.EventID, 
		et.EventName, 
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

AND a.AgencyID IN (SELECT number from GetTableFromListId(@AgencyIDs)) 

AND 
( 
	o_o.OfficerID IN (SELECT number from GetTableFromListId(@OfficerIDs)) 
)
AND
(
	o_o.OffenderID IN (SELECT number from GetTableFromListId(@OffenderIDs))
)

---- Drop temporary table ----
drop Table #tmpEventTraces

END

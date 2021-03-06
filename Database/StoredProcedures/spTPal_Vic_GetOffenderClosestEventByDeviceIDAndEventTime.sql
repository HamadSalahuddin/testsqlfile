USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_GetOffenderClosestEventByDeviceIDAndEventTime]    Script Date: 10/7/2020 9:52:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Vic_GetOffenderClosestEventByDeviceIDAndEventTime.sql
 * Created On: 05/13/2016         
 * Created By: H.Salahuddin 
 * Task #:     Task #10205 Proximity Alarms should compare previous offender traces
 * Purpose:    This sproc will return the closest offender's event by OffenderDeviceID and Victim event time.                
 *
 * Modified By: H.Salahuddin 05/21/2019 Task #13088 Optimized for performance.
 * Modified By: D. Riding 09/21/20 - Task #13913 Limit date range
				H.Salahuddin 09/23/2020 Task # 13972 Used the optional @ThresholdInMinutesForOffenderClosestEvent to get Offender closest event.i.e
				we may require closest event to determine victim proximity which may or may not return the result but there are other victim 
				alarms for which we definitely require offender closest event
				H.Salahuddin 10/02/2020 Task #13972. Removed clustered index. use '-'525600 to backup the time a year when 
				@ThresholdInMinutesForOffenderClosestEvent is null 
* Modified By: SABBASI 10/07/2020; Task#13972, Comment#16
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Vic_GetOffenderClosestEventByDeviceIDAndEventTime] 
	@DeviceIDs VARCHAR(MAX),
	@EventTime BIGINT,
	@ThresholdInMinutesForOffenderClosestEvent INT = NULL
	
AS
BEGIN
SET NOCOUNT ON; -- SABBASI-Review
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- SABBASI-Review
	 	
DECLARE @earliestEventTime BIGINT


	-- // Extract DeviceIDs into a temp table // --
SELECT [number]
INTO #tmpDeviceIDs
FROM Trackerpal.dbo.GetTableFromListId(@DeviceIDs);           -- Add function to GW DB

-- Constructing Common Table Expression to Hold Offender's closest event according to Victim's event time.
SET @earliestEventTime = dbo.ConvertDateToLong(DATEADD(mi, ISNULL(@ThresholdInMinutesForOffenderClosestEvent,-1440), dbo.ConvertLongToDate(@EventTime)));

	With OffenderClosestEventCTE AS
	(
		Select DeviceID, Max(EventTime) As EventTime
		From #tmpDeviceIDs As tempIds
		Inner Join Gateway.dbo.Events e On tempIds.number = e.DeviceID
			WHERE e.EventID < 270
			AND EventTime > @earliestEventTime
			AND EventTime < @EventTime
			AND ( e.EventID = 152 OR ( (e.Latitude <> 0 AND e.Longitude <> 0) ) )
			Group By DeviceID
	)

	-- // Main Query // --
SELECT evt.EventID,
	   evt.DeviceID,
       evt.EventTime,
       evt.Latitude,
       evt.Longitude 
FROM Gateway.dbo.Events (NOLOCK) As evt
  INNER JOIN OffenderClosestEventCTE As cte ON evt.DeviceID = cte.DeviceID 
  								       AND evt.EventTime = cte.EventTime
END


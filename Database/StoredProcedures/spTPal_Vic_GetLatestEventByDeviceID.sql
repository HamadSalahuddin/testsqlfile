USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_GetLatestEventByDeviceID]    Script Date: 6/1/2019 5:29:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Vic_GetLatestEventByDeviceID.sql
 * Created On: 03/13/2012         
 * Created By: R.Cole 
 * Task #:     
 * Purpose:                   
 *
 * Modified By: SABBASI - 03/21/2013 ; Need info for victim associated offender. I am trying to pull that info from 
 * Gateway Events table.
 *            : SABBASI  - 03/13/2013; Added condition to make sure e.Latitude <> 0 AND e.Longitude <> 0
 *	          : SABBASI - 03/15/2013; Added condition e.EventID < 270 so that the latest event returned is the one sent by Offender device.
 *            : SABBASI  - 04/09/2014; Removed condition  e.Latitude <> 0 AND e.Longitude <> 0 to get trinagulation events.
 *                                     Added EventID in the resultset
 *			  : H.Salahuddin - 05/13/2019 Task #13088. Used FullyQualified name for function call i.e. Trackerpal.dbo.GetTableFromListId(
			  : DRiding		05/21/19	  13088 - optimize for performance
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Vic_GetLatestEventByDeviceID] (
  @DeviceIDs VARCHAR(MAX)
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Extract DeviceIDs into a temp table // --
SELECT [number]
INTO #tmpDeviceIDs
FROM Trackerpal.dbo.GetTableFromListId(@DeviceIDs)   ;        -- Add function to GW DB


-- // // --
WITH cte 
AS
(select MAX(e.EventTime) max_eventtime, d.DeviceID from Gateway.dbo.Devices d
	inner join #tmpDeviceIDS t ON Convert(int, t.number) = d.DeviceID
	INNER JOIN Gateway.dbo.Events e ON e.EventTime = d.LastValidTime and d.DeviceID = e.DeviceID and e.EventID < 270
	group by d.DeviceID
)
select e.EventID, e.EventTime, e.Latitude, e.Longitude, e.DeviceID from cte
	inner join Gateway.dbo.Events e ON e.DeviceID = cte.DeviceID and e.EventTime = cte.max_eventtime


	

USE TrackerPal
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_GetTriangulation]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_GetTriangulation]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   Triangulation_GetAllTriangulationEvensSproc.sql
 * Created On: 22nd March 2011
 * Created By: Asif
 * Task #:     
 * Purpose:    Get Triangulation events               
 *
 * Modified By: R.Cole - 02/18/2011: Changed the EventID to 219,
 *                Reformatted to meet code standard.
 *  NOTE: This sproc will be renamed to meet standard before it 
 *        gets moved to production.  spTPal_Evt_GetTriangulation
 *              
 *              Asif - 03/11/2011: Added EventID 220 to the 
 *                WHERE clause, removed text compare on 'Triangulation'
 * SABBASI - 05/14/2014; Added order by EventPrimaryID DESC clause to get top records from the queue. 
 * Top records are likely to be recent one. So instead of order by time picked order by primary id. 
 * SABBASI; 05/24/2014; Task #5659; Added high water mark to make sure events picked once are not included in the result set on subsequent iterations of the SProc call.
 * SABBASI; 06/04/2014; Task #5659; Changing high water mark mechanism by saving water mark in DB. 
 * SABBASI; 17/06/2014; Task #5659; Combined the resultset with Gateway events table to get street address value that contains 
 * Cell tower information for the triangulation event.
 * RCole: 7/13/2014: Revised for Performance, removed SELECT * and modified inner join to Events table (put key fields in correct order and removed EventParameter
 *        since it's not part of the Events table PK)
 * RCole: 7/31/2014: Forced main query to use the correct index which resolved a significant performance issue.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Evt_GetTriangulation] (
	@RecordThrottle INT
)	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @HighWaterMark BIGINT,
            @NewMark BIGINT            
          
  -- // Get the HighWater Mark  // --
 SET @HighWaterMark = (SELECT RTM_HighID FROM RTM_TableState WHERE RTM_TableName LIKE 'Triangulation')
 
 SELECT TOP (@RecordThrottle) [EventPrimaryID],
	       [DeviceID],
	       [EventTime],
	       [EventDateTime],
	       [ReceivedTime],
	       [TrackerNumber],
		     [EventID],
		     [EventParameter],
		     [AlarmType],
		     [AlarmAssignmentStatusID],
		     [AlarmAssignmentStatusName],
		     [EventName],
		     [Longitude],
		     [Latitude],
		     --[Address],
		     [OffenderID],
		     [NoteCount],
		     [AlarmID],
		     [GpsValid],
		     [GpsValidSatellites],
		     [GeoRule],
		     [SO],
		     [OPR],
		     [EventTypeGroupID],
		     [OfficerID],
		     [AgencyID],
		     [AcceptedDate],
		     [AcceptedBy],
		     [ActivateDate],
		     [DeactivateDate],
		     [EventQueueID],
		     [OffenderName],
		     [OffenderDeleted]
	INTO #tmpTriangulationEvents 
	FROM [rprtEventsBucket1] WITH (INDEX(PK__rprtEventBucket1__57BDDBAA))
	WHERE EventPrimaryID  > @HighWaterMark
	  AND EventID IN (152,153) 
	  AND [Longitude] = 0 
	  AND [Latitude] = 0 
	  --AND [GpsValid] = 0
	  AND (([Address] IS NULL) OR ([Address]  LIKE 'unavailable'))
order by EventPrimaryID 

 SET @NewMark = (SELECT ISNULL(MAX(EventPrimaryID),@HighWaterMark) FROM #tmpTriangulationEvents)
 
 UPDATE RTM_TableState
    SET RTM_HighID = @NewMark
--    SET RTM_HighTime = @Now
    WHERE RTM_TableName LIKE 'Triangulation'
    
-- Get Triangulation records  
SELECT te.EventPrimaryID,
	     te.DeviceID,
	     te.EventTime,
	     te.EventDateTime,
	     te.ReceivedTime,
	     te.TrackerNumber,
		   te.EventID,
		   te.EventParameter,
		   te.AlarmType,
		   te.AlarmAssignmentStatusID,
		   te.AlarmAssignmentStatusName,
		   te.EventName,
		   te.Longitude,
		   te.Latitude,
		     --[Address],
		   te.OffenderID,
		   te.NoteCount,
		   te.AlarmID,
		   te.GpsValid,
		   te.GpsValidSatellites,
		   te.GeoRule,
		   te.SO,
		   te.OPR,
		   te.EventTypeGroupID,
		   te.OfficerID,
		   te.AgencyID,
		   te.AcceptedDate,
		   te.AcceptedBy,
		   te.ActivateDate,
		   te.DeactivateDate,
		   te.EventQueueID,
		   te.OffenderName,
		   te.OffenderDeleted,
       gwe.StreetAddress AS [Address]
FROM #tmpTriangulationEvents te
  INNER JOIN Gateway.dbo.Events gwe ON te.DeviceID = gwe.DeviceID
         AND te.EventTime = gwe.EventTime  
         AND te.EventID = gwe.EventID
--         AND te.EventParameter = gwe.EventParameter
         
  -- // Clean Up // --
  DROP TABLE #tmpTriangulationEvents  
END
GO


GRANT EXECUTE ON [dbo].[spTPal_Evt_GetTriangulation] TO db_dml;
GO



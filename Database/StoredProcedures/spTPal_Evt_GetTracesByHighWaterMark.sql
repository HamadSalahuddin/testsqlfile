USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_GetTracesByHighWaterMark]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_GetTracesByHighWaterMark]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- FileName:    spTPal_Evt_GetTracesByHighWaterMark.sql
-- Author:		  Sajid Abbasi
-- Create date: 17-Aug-2010
-- Description:	We want Tracker events for the given 
--              Offenders after high water mark
--              that is the ID of last event client received
-- Modified By: R.Cole - 8/17/2010: Added comments for Sajid
--              R.Cole - 8/18/2010: Removed OffenderID and EventTime 
--                from the Param list. Modified the Logic somewhat,
--                If an EventPrimaryID is present, we will return all traces 
--                since the EventPrimaryID.  If @EventPrimaryID IS NULL,
--                get the latest trace only.
--              S.Florek - 12/16/2010: Performance Tweak
-- =====================================================
CREATE PROCEDURE [dbo].[spTPal_Evt_GetTracesByHighWaterMark] (
	@DeviceID BIGINT,
  @EventPrimaryID BIGINT = NULL	
)
AS

IF @EventPrimaryID IS NULL
  -- // Get the latest event for this device // --
  BEGIN
    SELECT EventPrimaryID,
           DeviceID,
           EventTime,
           EventDateTime,
           ReceivedTime,
           TrackerNumber,
           EventID,
           EventParameter,
           AlarmType,
           AlarmAssignmentStatusID,
           AlarmAssignmentStatusName,
           EventName,
           Longitude,
           Latitude,
           [Address],
           OffenderID,
           NoteCount,
           AlarmID,
           GpsValid,
           GpsValidSatellites,
           GeoRule,
           SO,
           OPR,
           EventTypeGroupID,
           OfficerID,
           AgencyID,
           AcceptedDate,
           AcceptedBy,
           DeactivateDate,
           EventQueueID,
           OffenderName,
           OffenderDeleted
    FROM rprtEventsBucket1 (NOLOCK)
    WHERE DeviceID = @DeviceID
      AND EventPrimaryID = (SELECT MAX(EventPrimaryID)
                            FROM rprtEventsBucket1 (NOLOCK) b1
                            WHERE b1.DeviceID = @DeviceID)      
  END
ELSE IF @EventPrimaryID IS NOT NULL
  -- // Return all Events after the HighWater Mark // --
  BEGIN
    SELECT EventPrimaryID,
           DeviceID,
           EventTime,
           EventDateTime,
           ReceivedTime,
           TrackerNumber,
	         EventID,    
           EventParameter,
           AlarmType,
           AlarmAssignmentStatusID,
           AlarmAssignmentStatusName,
           EventName,
           Longitude,
           Latitude,
           [Address],
           OffenderID,
           NoteCount,
           AlarmID,
           GpsValid,
           GpsValidSatellites,
           GeoRule,
           SO,
           OPR,
           EventTypeGroupID,
           OfficerID,
           AgencyID,
           AcceptedDate,
           AcceptedBy,
           ActivateDate,
           DeactivateDate,
           EventQueueID,
           OffenderName,
           OffenderDeleted
    FROM rprtEventsBucket1 (NOLOCK)
    WHERE DeviceID = @DeviceID
      AND EventPrimaryID > @EventPrimaryID  
  END
GO

GRANT EXECUTE ON [dbo].[spTPal_Evt_GetTracesByHighWaterMark] TO db_dml;
GO
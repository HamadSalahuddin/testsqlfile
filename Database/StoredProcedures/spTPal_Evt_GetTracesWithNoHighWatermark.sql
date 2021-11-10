USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_GetTracesWithNoHighWatermark]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_GetTracesWithNoHighWatermark]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Evt_GetTracesWithNoHighWatermark.sql
 * Created On: 08/17/2010
 * Created By: R.Cole
 * Task #:     <Redmine #>      
 * Purpose:    Get the latest event (within the last 5 minutes)
 *             for a given offender.
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Evt_GetTracesWithNoHighWatermark] (
  	@OffenderID INT,
  	@DeviceID BIGINT
) 
AS
SET NOCOUNT ON;

-- // Declare Var // --
DECLARE @Now DATETIME
SET @Now = DATEADD(MINUTE, -5, GETDATE())
   
-- // Main Query // --
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
WHERE OffenderID = @OffenderID
  AND DeviceID = @DeviceID
  AND EventDateTime > @Now
  AND EventPrimaryID = (SELECT MAX(EventPrimaryID)
                        FROM rprtEventsBucket1 (NOLOCK) bucket1 
                        WHERE bucket1.DeviceID = @DeviceID
                          AND bucket1.OffenderID = @OffenderID
                          AND bucket1.EventDateTime > @Now)
GO

-- // Grant Permissions // --
GRANT EXECUTE ON [dbo].[spTPal_Evt_GetTracesWithNoHighWatermark] TO db_dml;
GO
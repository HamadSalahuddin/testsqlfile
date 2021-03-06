USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_MessagingDemo]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_MessagingDemo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Evt_MessagingDemo.sql
 * Created On: 05/21/2010
 * Created By: R.Cole
 * Task #:     <Redmine #>      
 * Purpose:    Simulate SQLStream for the messaging PoC
 *
 * Modified By: R.Cole - 6/15/2010: Changed the location where
 *                the HighTime is stored.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Evt_MessagingDemo] (  
  @Now DATETIME
)
AS
SET NOCOUNT ON;

-- // Declare Var // --
DECLARE @Checkpoint DATETIME

-- // Get the DateTime of the last row handled by SQLStream // --
SET @Checkpoint = (SELECT RTM_HighTime 
                   FROM RTM_TableState 
                   WHERE RTM_TableName LIKE 'rprtEventsBucket1')
   
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
FROM rprtEventsBucket1
WHERE EventDateTime > @Checkpoint AND EventDateTime <= @Now

-- Update HighTime. Set it equal to date time now
UPDATE RTM_TableState 
  SET RTM_HighTime = @Now
  WHERE RTM_TableName LIKE 'rprtEventsBucket1'
GO

GRANT EXECUTE ON [dbo].[spTPal_Evt_MessagingDemo] TO db_dml;
GO
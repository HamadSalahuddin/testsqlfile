USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Evt_MessagingDemo]    Script Date: 05/27/2010 14:00:15 ******/
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
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Evt_MessagingDemo]  
@Now DATETIME
AS
SET NOCOUNT ON;

-- // Declare Var // --
DECLARE @Checkpoint DATETIME

-- // Get the DateTime of the last row handled by SQLStream // --
SET @Checkpoint = (SELECT SQLS_highTime 
                   FROM SQLS_TableReader_State 
                   WHERE SQLS_tableName LIKE 'rprtEventsBucket1')
   
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
WHERE EventDateTime >= @Checkpoint AND EventDateTime <= @Now
-- Update HighTime. Set it equal to date time now
UPDATE SQLS_TableReader_State 
SET  SQLS_highTime = @Now
WHERE SQLS_tableName LIKE 'rprtEventsBucket1'
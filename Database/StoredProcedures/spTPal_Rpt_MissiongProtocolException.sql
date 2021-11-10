USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_MissingProtocolException]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_MissingProtocolException]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_MissingProtocolException.sql
 * Created On: 5/7/2012
 * Created By: R.Cole
 * Task #:     3357      
 * Purpose:    Return results to the new NoProtocols found 
 *             report               
 *
 * Modified By: R.Cole - 5/16/2012: Tweaked @StartDate and
 *               @EndDate, altered WHERE so date check runs
 *               first.
 *              R.Cole - 5/16/2012: Added code to store
 *              the missed protocol alarm for alarming and research
 *              R.Cole - 12/11/2012: Added DST change handling
 *              code, removed commented code.
 *              R.Cole - 05/15/2013: Fixed a time conversion
 *              bug.  Offset was being applied in hours rather
 *              than minutes.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_MissingProtocolException] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  
DECLARE @StartDate DATETIME,
        @EndDate DATETIME,
        @Truncate INT,
        @UTCOffset INT

SET @StartDate = DATEADD(hh, -1, GETDATE())
SET @EndDate = GETDATE()
SET @Truncate = (SELECT COUNT(*) FROM [dbo].[MissingProtocols])
SET @UTCOffset = TrackerPal.dbo.fnGetMSTOffset(8)                 -- MountainTime

-- // Clean up old data // --
IF ISNULL(@Truncate, -1) > 0
  TRUNCATE TABLE [dbo].[MissingProtocols]

-- // Main Query // --
INSERT INTO [dbo].[MissingProtocols] (AlarmID, Agency, Officer, Offender, Alarm, AlarmProtocolSetName, AlarmTimeMT)
  SELECT DISTINCT Alarm.AlarmID,
         Agency.Agency AS Agency,
         Officer.FirstName + ' ' + Officer.LastName AS Officer,
         Offender.FirstName + ' ' + Offender.LastName AS Offender,
         et.AbbrevEventType AS Alarm,
         aps.AlarmProtocolSetName,
         DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS AlarmTimeMT 
  FROM AlarmNote (NOLOCK)
	  INNER JOIN Alarm (NOLOCK) ON AlarmNote.AlarmID = Alarm.AlarmID
	  INNER JOIN Offender (NOLOCK) ON Alarm.OffenderID = Offender.OffenderID
	  INNER JOIN Agency (NOLOCK) ON Offender.AgencyID = Agency.AgencyID
	  INNER JOIN Offender_Officer (NOLOCK) ON Offender.OffenderID = Offender_Officer.OffenderID
	  INNER JOIN Officer (NOLOCK) ON Offender_Officer.OfficerID = Officer.OfficerID
	  INNER JOIN EventType et (NOLOCK) ON Alarm.EventTypeID = et.EventTypeID
    INNER JOIN AlarmProtocolEvent ape (NOLOCK) ON et.EventTypeID = ape.GatewayEventID 
    INNER JOIN Offender_AlarmProtocolSet oaps (NOLOCK) ON Offender.OffenderID = oaps.OffenderID
    INNER JOIN AlarmProtocolSet aps (NOLOCK) ON oaps.AlarmProtocolSetID = aps.AlarmProtocolSetID
    INNER JOIN AlarmProtocolAction apa (NOLOCK) ON aps.AlarmProtocolSetID = apa.AlarmProtocolSetID
           AND ape.AlarmProtocolEventID = apa.AlarmProtocolEventID
  WHERE AlarmNote.CreatedDate BETWEEN @StartDate AND @EndDate
    AND AlarmNote.Note LIKE 'No protocols%'    -- assigned to this alarm.'
    AND apa.Deleted = 0               -- Filter out deleted protocol steps
    AND oaps.Deleted = 0              -- Filter out protocol sets no longer associated with an offender
    AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)
  ORDER BY Alarm.AlarmID,
           Agency.Agency,
           DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) 

SELECT AlarmID,
       Agency,
       Officer,
       Offender,
       Alarm,
       AlarmProtocolSetName,
       AlarmTimeMT
FROM dbo.MissingProtocols
ORDER BY AlarmID,
         Agency,
         AlarmTimeMT
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_MissingProtocolException] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_PhillyMonitoringHistory]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_PhillyMonitoringHistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_PhillyMonitoringHistory.sql
 * Created On: 07/17/2012
 * Created By: R.Cole
 * Task #:     3491
 * Purpose:    Return data for the Monitoring History Report,
 *             Philly Juv. specific 
 *
 * ModifiedBy: R.Cole - 11/14/2012: Switched the join to the
 *    DeactivationReason table to LEFT OUTER which resolved 
 *    an issue where valid records were exluded.                     
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_PhillyMonitoringHistory] (
  @RoleID INT = NULL,
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @AgencyID INT,
        @RunDate CHAR(10),
        @UTCOffset INT

-- // Set Agency (Philly Juv) // --
SET @AgencyID = 972

-- // Set Report RunDate // --
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi, @UTCOffset, GETDATE()),110)

--SET @RoleID = NULL
--SET @StartDate = '2012-04-15'
--SET @EndDate = GETDATE()

-- // Handle UTCOffsets based on who is running the report // --
IF @RoleID = 4                                                       -- App Admin/SuperUser
  SET @UTCOffset = dbo.fnGetMSTOffset(8)      -- MountainTime
ELSE                                                                 -- Agency User
  SET @UTCOffset = dbo.fnGetUtcOffset(@AgencyID)

-- // Account for NULL Date Params // --
IF ((@StartDate IS NULL) OR (@EndDate IS NULL))
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, DATEADD(mi, @UTCOffset, GETDATE()))
    SET @EndDate = DATEADD(MI, @UTCOffset, GETDATE())
  END 

-- // Main Query // --
SELECT DISTINCT Offender.OffenderID,
        Offender.FirstName + ' ' + Offender.LastName AS [Offender],
        Offender.CaseNumber,
        Agency.Agency,
        Officer.FirstName + ' ' + Officer.LastName AS [Officer],
        CASE WHEN Offender.ReferralProgramID IN (1,2) THEN (SELECT ProgramName 
                                                            FROM ReferralProgramAgency 
                                                            WHERE Offender.ReferralProgramID = ReferralProgramAgency.ReferralProgramAgencyID)
             ELSE ReferralProgram.ProgramName
        END AS [ProgramName],
        ReferralProgramSubType.ProgramName AS [SubTypeProgramName],
        LEFT(Tracker.TrackerName,8) AS [Device],
        DATEADD(MI, @UTCOffset, ota.ActivateDate) AS [ActivateDate],
        CASE WHEN (DATEADD(MI, @UTCOffset, ota.DeactivateDate) > @EndDate) THEN NULL
            ELSE DATEADD(MI, @UTCOffset, ota.DeactivateDate)
        END AS [DeactivateDate],
        CASE WHEN ((DATEADD(MI, @UTCOffset, ota.DeactivateDate) > @EndDate) OR (ota.DeactivateDate IS NULL)) THEN ''
            ELSE tdr.TrackerDeactivationReasonName
        END AS [DeactivationReason],
        CASE WHEN (DATEADD(MI, @UTCOffset, ota.DeactivateDate) > @EndDate) THEN DATEDIFF(DAY, ota.ActivateDate, @EndDate)
             WHEN (DATEADD(MI, @UTCOffset, ota.DeactivateDate) IS NULL) THEN DATEDIFF(DAY, ota.ActivateDate, @EndDate)
             ELSE DATEDIFF(DAY, ota.ActivateDate, ota.DeactivateDate)
        END AS [TrackingDuration],       
        @RunDate AS [RunDate],
        CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
        CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]       
FROM Offender
  INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
  INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
  INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID  
  INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
  INNER JOIN Tracker ON ota.TrackerID = Tracker.TrackerID
  LEFT OUTER JOIN TrackerDeactivationReason tdr ON ota.TrackerDeactivationReasonID = tdr.TrackerDeactivationReasonID
  INNER JOIN ReferralProgram ON Offender.ReferralProgramID = ReferralProgram.ReferralProgramID  
  LEFT OUTER JOIN ReferralProgramSubType ON Offender.ReferralProgramSubTypeID = ReferralProgramSubType.ReferralProgramSubTypeID
WHERE Agency.AgencyID = @AgencyID
  AND DATEADD(MI,@UTCOffset, ota.ActivateDate) < @EndDate
  AND (DATEADD(mi,@UTCOffset,ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID) 
GO

GRANT EXECUTE ON [spTPal_Rpt_PhillyMonitoringHistory] TO [db_dml]
GO
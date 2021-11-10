USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_MonitoringHistory]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_MonitoringHistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_MonitoringHistory.sql
 * Created On: 10/10/2011
 * Created By: R.Cole
 * Task #:     2742
 * Purpose:    Return data for the Monitoring History Report               
 *
 * Modified By: R.Cole - 10/12/2011: Removed OfficerID as a
 *                parameter, added AgencyID
 *              R.Cole - 10/13/2011: Added time segment back
 *                to the DateTimes. Removed deprecated code. 
 *                Added ReferralSource.
 *              R.Cole - 02/06/2012: Per #2732/#2742 - Added OTD
 *                Serial Number.  Per #2742 Rewrote WHERE clause
 *                to show all active devices for the timeframe
 *              R.Cole - 3/15/2012: Per #2677 and #2742 Added 
 *                code to handle Distributors, and Application Admins.
 *              R.Cole - 4/10/2012: Fixed a bug in where clause
 *              R.Cole - 11/14/2012: Switched the join to the
 *                DeactivationReason table to LEFT OUTER which
 *                resolved an issue where valid records were exluded.       
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_MonitoringHistory] (
  @AgencyID INT,
  @DistributorID INT = NULL,
  @RoleID INT = NULL,
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @RunDate CHAR(10),
        @UTCOffset INT

-- // Handle UTCOffsets based on who is running the report // --
IF @DistributorID > 0 --IS NOT NULL                                       -- Distributor User
  SET @UTCOffset = dbo.fnGetDistributorUtcOffset(@DistributorID)
ELSE IF @RoleID = 4                                                       -- App Admin/SuperUser
  SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
ELSE                                                                      -- Agency User
  SET @UTCOffset = dbo.fnGetUtcOffset(@AgencyID)

-- // Set Report RunDate // --
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi, @UTCOffset, GETDATE()),110)

-- // Account for NULL Date Params // --
IF ((@StartDate IS NULL) OR (@EndDate IS NULL))
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, DATEADD(mi, @UTCOffset, GETDATE()))
    SET @EndDate = DATEADD(MI, @UTCOffset, GETDATE())
  END   
   
-- // Main Query // --
IF ((@DistributorID IS NOT NULL) AND (@AgencyID = -1))  
  -- // Get Resultset for all Agencies belonging to Distributor // --
  BEGIN
    SELECT DISTINCT Offender.OffenderID,
           Offender.FirstName + ' ' + Offender.LastName AS [Offender],
           Offender.CaseNumber,
           Agency.Agency,
           Officer.FirstName + ' ' + Officer.LastName AS [Officer],
           ISNULL(ReferralProgram.ProgramName,'') AS ProgramName,
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
      LEFT OUTER JOIN ReferralProgram ON Offender.ReferralProgramID = ReferralProgram.ReferralProgramID
    WHERE Agency.DistributorID = @DistributorID
      AND DATEADD(MI,@UTCOffset, ota.ActivateDate) < @EndDate
      AND (DATEADD(mi,@UTCOffset,ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)
      AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID)                           
  END
ELSE
  IF (@AgencyID > -1)
    -- // Get Resultset for Single Agency // --
    BEGIN
      SELECT DISTINCT Offender.OffenderID,
             Offender.FirstName + ' ' + Offender.LastName AS [Offender],
             Offender.CaseNumber,
             Agency.Agency,
             Officer.FirstName + ' ' + Officer.LastName AS [Officer],
             ISNULL(ReferralProgram.ProgramName,'') AS ProgramName,
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
        LEFT OUTER JOIN ReferralProgram ON Offender.ReferralProgramID = ReferralProgram.ReferralProgramID
      WHERE Agency.AgencyID = @AgencyID
        AND DATEADD(MI,@UTCOffset, ota.ActivateDate) < @EndDate
        AND (DATEADD(mi,@UTCOffset,ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)
        AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID)                           
    END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_MonitoringHistory] TO db_dml;
GO
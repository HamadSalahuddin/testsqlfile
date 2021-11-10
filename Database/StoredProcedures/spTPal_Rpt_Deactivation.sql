USE [TrackerPal]
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_Deactivation]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_Deactivation]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_Deactivation.sql
 * Created On: 10/07/2011
 * Created By: R.Cole
 * Task #:     2744
 * Purpose:    Return data for the Deactivation Report               
 *
 * Modified By: R.Cole - 10/12/2011: Removed OfficerID as a
 *                parameter, added AgencyID
 *              R.Cole - 10/13/2011: Added time segment back
 *                to the DateTimes. Removed some deprecated
 *                code.
 *              R.Cole - 3/13/2012: Added code to handle Distributors,
 *                and Application Admins.    
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_Deactivation] (
  @AgencyID INT,
  @DistributorID INT = NULL,
  @RoleID INT = NULL,
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
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

-- // Set Report Dates // --
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,GETDATE()),110)

-- // Account for NULL StartDate // --
IF (@StartDate IS NULL)
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, DATEADD(mi,@UTCOffset,GETDATE()))
    SET @EndDate = DATEADD(mi,@UTCOffset,GETDATE())
  END
  
-- // Main Query // --
IF ((@DistributorID IS NOT NULL) AND (@AgencyID = -1))  
  -- // Get Resultset for all Agencies belonging to Distributor // --
  BEGIN
    SELECT DISTINCT Offender.OffenderID,
           Offender.FirstName + ' ' + Offender.LastName AS Offender,
           Offender.CaseNumber,
           Agency.Agency,
           Officer.FirstName + ' ' + Officer.LastName AS [Officer],       
           LEFT(Tracker.TrackerName,8) AS SerialNumber,
           DATEADD(MI, @UTCOffset, ota.DeactivateDate) AS [DeactivateDate],
    --       CONVERT(CHAR(10),DATEADD(MI, @UTCOffset, ota.DeactivateDate),110) AS [DeactivateDate],
           DATEDIFF(DAY,ota.ActivateDate, ota.DeactivateDate) AS TrackingDuration,
           tdr.TrackerDeactivationReasonName AS DeactivationReason,
           CASE Offender.Deleted WHEN 1 THEN DATEADD(MI, @UTCOffset, Offender.ModifiedDate) ELSE '' END AS [ModifiedDate],
    --       CASE Offender.Deleted WHEN 1 THEN CONVERT(CHAR(10), DATEADD(mi, @UTCOffset, Offender.ModifiedDate),110) ELSE '' END AS ModifiedDate,
           CASE Offender.Deleted WHEN 1 THEN 'Yes' ELSE 'No' END AS Deleted,
           @RunDate AS [RunDate],
           CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
           CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]       
    FROM Offender
      INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
      INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
      INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
      INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
      INNER JOIN Tracker ON ota.TrackerID = Tracker.TrackerID
      INNER JOIN TrackerDeactivationReason tdr ON ota.TrackerDeactivationReasonID = tdr.TrackerDeactivationReasonID
    WHERE Agency.DistributorID = @DistributorID
      AND ota.DeactivateDate IS NOT NULL
      AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset, ota.DeactivateDate) AS FLOAT)) AS DATETIME) BETWEEN (CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME)) AND (CAST(FLOOR(CAST(@EndDate AS FLOAT)) AS DATETIME))
--      AND DATEADD(MI, @UTCOffset,ota.DeactivateDate) BETWEEN @StartDate AND @EndDate
	    AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker WHERE TrackerID = ota.TrackerID)
  END
ELSE
  IF (@AgencyID > -1)
    -- // Get Resultset for Single Agency // --
    BEGIN
      SELECT DISTINCT Offender.OffenderID,
             Offender.FirstName + ' ' + Offender.LastName AS Offender,
             Offender.CaseNumber,
             Agency.Agency,
             Officer.FirstName + ' ' + Officer.LastName AS [Officer],       
             LEFT(Tracker.TrackerName,8) AS SerialNumber,
             DATEADD(MI, @UTCOffset, ota.DeactivateDate) AS [DeactivateDate],
      --       CONVERT(CHAR(10),DATEADD(MI, @UTCOffset, ota.DeactivateDate),110) AS [DeactivateDate],
             DATEDIFF(DAY,ota.ActivateDate, ota.DeactivateDate) AS TrackingDuration,
             tdr.TrackerDeactivationReasonName AS DeactivationReason,
             CASE Offender.Deleted WHEN 1 THEN DATEADD(MI, @UTCOffset, Offender.ModifiedDate) ELSE '' END AS [ModifiedDate],
      --       CASE Offender.Deleted WHEN 1 THEN CONVERT(CHAR(10), DATEADD(mi, @UTCOffset, Offender.ModifiedDate),110) ELSE '' END AS ModifiedDate,
             CASE Offender.Deleted WHEN 1 THEN 'Yes' ELSE 'No' END AS Deleted,
             @RunDate AS [RunDate],
             CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
             CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]       
      FROM Offender
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
        INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
        INNER JOIN Tracker ON ota.TrackerID = Tracker.TrackerID
        INNER JOIN TrackerDeactivationReason tdr ON ota.TrackerDeactivationReasonID = tdr.TrackerDeactivationReasonID
      WHERE Agency.AgencyID = @AgencyID
        AND ota.DeactivateDate IS NOT NULL
        AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset, ota.DeactivateDate) AS FLOAT)) AS DATETIME) BETWEEN (CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME)) AND (CAST(FLOOR(CAST(@EndDate AS FLOAT)) AS DATETIME))
--        AND DATEADD(MI, @UTCOffset,ota.DeactivateDate) BETWEEN @StartDate AND @EndDate
	      AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker WHERE TrackerID = ota.TrackerID)	    
	  END 
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_Deactivation] TO db_dml;
GO
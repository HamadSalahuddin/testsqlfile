USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_OffenderAlarmSummary]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_OffenderAlarmSummary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_OffenderAlarmSummary.sql
 * Created On: 08/22/2011         
 * Created By: R.Cole  
 * Task #:     #2627
 * Purpose:    Return data for the OffenderAlarmSummary
 *             Report.               
 *
 * Modified By: R.Cole - 12/07/2011: Found and fixed an error
 *                in the handling of UTC to Agency time conversions.
 *              R.Cole - 01/26/2012: Added Start and End dates
 *                per #2693.  Defaulted to last 24hrs in the event
 *                of NULL dates.
 *              R.Cole - 3/5/2012: Added code to handle Distributors,
 *                and Application Admins.
 *              R.Cole - 3/26/2012: Fix handling of NULL middle names.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_OffenderAlarmSummary] (
  @OfficerID INT,
  @AgencyID INT,
  @DistributorID INT = NULL,
  @RoleID INT = NULL,
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL  
) 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Declare Var's // --
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
SET @RunDate = CONVERT(CHAR(10),DATEADD(mi,@UTCOffset,GETDATE()),110)

-- // Account for NULL StartDate // --
IF (@StartDate IS NULL)
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, GETDATE())
    SET @EndDate = GETDATE()
  END

-- // Account for NULL EndDate when Distributor selects All Agencies, All Officers // --
IF (@EndDate IS NULL)
  SET @EndDate = @StartDate

-- // Main Query // --
IF ((@DistributorID IS NOT NULL) AND (@AgencyID = -1))
  BEGIN
    -- // Get Resultset for All Agencies belonging to Distributor and All Officers // --
    SELECT Agency.Agency,
           Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS 'Officer',
           Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS 'Offender',
           EventType.AbbrevEventType AS Alarm,
           Count(DISTINCT(AlarmID)) AS Alarms,
           @RunDate AS [RunDate],
           CONVERT(CHAR(10),@StartDate,110) AS [StartDate],
           CONVERT(CHAR(10),@StartDate,110) AS [EndDate]        -- StartDate and EndDate are the same in this case
    FROM Alarm WITH (NOLOCK)
      INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
      INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
      INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
      INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
      INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
    WHERE Agency.DistributorID = @DistributorID
      AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME)
      AND Agency.Deleted = 0
      AND Officer.Deleted = 0
    GROUP BY Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
             EventType.AbbrevEventType   
  END
ELSE 
  IF ((@AgencyID > -1) AND (@OfficerID = -1)) 
    -- // Get Resultset for Single Agency, All Officers // --
    BEGIN
      SELECT Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS 'Officer',
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS 'Offender',
             EventType.AbbrevEventType AS Alarm,
             COUNT(DISTINCT(AlarmID)) AS Alarms,
             @RunDate AS [RunDate],
             CONVERT(CHAR(10),@StartDate,110) AS [StartDate],
             CONVERT(CHAR(10),@EndDate,110) AS [EndDate]
      FROM Alarm WITH (NOLOCK)
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
      WHERE Agency.AgencyID = @AgencyID
        AND (CONVERT(CHAR(10),DATEADD(mi,@UTCOffset,Alarm.EventDisplayTime),110) BETWEEN @StartDate AND @EndDate)
      GROUP BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               EventType.AbbrevEventType
    END
ELSE
  IF ((@AgencyID > -1) AND (@OfficerID > -1))
    BEGIN
      -- // Get Resultset for Single Agency, Single Officer // -- 
      SELECT Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS 'Officer',
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS 'Offender',
             EventType.AbbrevEventType AS Alarm,
             COUNT(DISTINCT(AlarmID)) AS Alarms,
             @RunDate AS [RunDate],
             CONVERT(CHAR(10),@StartDate,110) AS [StartDate],
             CONVERT(CHAR(10),@EndDate,110) AS [EndDate]
      FROM Alarm WITH (NOLOCK)
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
      WHERE Officer.OfficerID = @OfficerID 
        AND (CONVERT(CHAR(10),DATEADD(mi,@UTCOffset,Alarm.EventDisplayTime),110) BETWEEN @StartDate AND @EndDate)
      GROUP BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               EventType.AbbrevEventType
  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_OffenderAlarmSummary] TO db_dml;
GO
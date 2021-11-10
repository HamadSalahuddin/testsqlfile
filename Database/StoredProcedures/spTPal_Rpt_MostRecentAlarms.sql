USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_MostRecentAlarms]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_MostRecentAlarms]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_MostRecentAlarms.sql
 * Created On: 08/22/2011         
 * Created By: R.Cole  
 * Task #:     #2627 
 * Purpose:    Returns data for the MostRecentAlarms Report               
 *
 * Modified By: R.Cole - 12/07/2011: Found and fixed an error
 *                in the handling of UTC to Agency time conversions.
 *              R.Cole - 12/08/2011: Fixed an issue with the 
 *                displayed event date/time.
 *              R.Cole - 3/5/2012: Added code to handle Distributors,
 *                and Application Admins. 
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_MostRecentAlarms] (
  @OfficerID INT,
  @AgencyID INT,
  @DistributorID INT = NULL,
  @RoleID INT = NULL  
) 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Declare Var's // --
DECLARE @RunDate CHAR(10),
        @UTCOffset INT,
        @StartDate DATETIME

-- // Handle UTCOffsets based on who is running the report // --
IF @DistributorID > 0 --IS NOT NULL                                       -- Distributor User
  SET @UTCOffset = dbo.fnGetDistributorUtcOffset(@DistributorID)
ELSE IF @RoleID = 4                                                       -- App Admin/SuperUser
  SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
ELSE                                                                      -- Agency User
  SET @UTCOffset = dbo.fnGetUtcOffset(@AgencyID)

-- // Set Report Dates // --
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,GETDATE()),110)
SET @StartDate = CAST(FLOOR(CAST(DATEADD(mi,@UTCOffset,GETDATE()) AS FLOAT)) AS DATETIME)

-- // Main Query // --
IF ((@DistributorID IS NOT NULL) AND (@AgencyID = -1))
  BEGIN
    -- // Get Resultset for All Agencies belonging to Distributor and All Officers // --
    SELECT DISTINCT Alarm.AlarmID,
           Agency.Agency,
           Officer.FirstName + ' ' + ISNULL(Officer.MiddleName, '') + ' ' + Officer.LastName AS 'Officer',
           Offender.FirstName + ' ' + ISNULL(Offender.MiddleName, '') + ' ' + Offender.LastName AS 'Offender',
           EventType.AbbrevEventType AS Alarm,
           CONVERT(CHAR(20), DATEADD(mi,@UTCOffset,Alarm.EventDisplayTime),22) AS AlarmTime,
           @RunDate AS [RunDate]
    FROM ALARM WITH (NOLOCK)
      INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
      INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
      INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
      INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
      INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
    WHERE Agency.DistributorID = @DistributorID
      AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) = @StartDate
      AND Agency.Deleted = 0
      AND Officer.Deleted = 0
    GROUP BY Agency.Agency,
             Officer.FirstName + ' ' + ISNULL(Officer.MiddleName, '') + ' ' + Officer.LastName,
             Offender.FirstName + ' ' + ISNULL(Offender.MiddleName, '') + ' ' + Offender.Lastname,
             EventType.AbbrevEventType,
             Alarm.EventDisplayTime,
             Alarm.AlarmID
  END
ELSE 
  IF ((@AgencyID > -1) AND (@OfficerID = -1)) 
    BEGIN
      -- // Get Resultset for Single Agency, All Officers // --
      SELECT DISTINCT Alarm.AlarmID,
             Agency.Agency,
             Officer.FirstName + ' ' + ISNULL(Officer.MiddleName, '') + ' ' + Officer.LastName AS 'Officer',
             Offender.FirstName + ' ' + ISNULL(Offender.MiddleName, '') + ' ' + Offender.LastName AS 'Offender',
             EventType.AbbrevEventType AS Alarm,
             CONVERT(CHAR(20), DATEADD(mi,@UTCOffset,Alarm.EventDisplayTime), 22) AS AlarmTime,
             @RunDate AS [RunDate]
      FROM Alarm WITH (NOLOCK)
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
      WHERE Agency.AgencyID = @AgencyID                                     -- Return data for agency
        AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) = @StartDate
--        AND CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,Alarm.EventDisplayTime), 110) = @RunDate
      GROUP BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL(Officer.MiddleName, '') + ' ' + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL(Offender.Middlename, '') + ' ' + Offender.LastName,
               EventType.AbbrevEventType,
               Alarm.EventDisplayTime,
               Alarm.AlarmID      
    END
ELSE
  IF ((@AgencyID > -1) AND (@OfficerID > -1))
    BEGIN
      -- // Get Resultset for Single Agency, Single Officer // --    
      SELECT DISTINCT Alarm.AlarmID,
             Agency.Agency,
             Officer.FirstName + ' ' + ISNULL(Officer.MiddleName, '') + ' ' + Officer.LastName AS 'Officer',
             Offender.FirstName + ' ' + ISNULL(Offender.Middlename, '') + ' ' + Offender.LastName AS 'Offender',
             EventType.AbbrevEventType AS Alarm,
             CONVERT(CHAR(20), DATEADD(mi,@UTCOffset,Alarm.EventDisplayTime), 22) AS AlarmTime,
             @RunDate AS [RunDate]
      FROM Alarm WITH (NOLOCK)
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
      WHERE Officer.OfficerID = @OfficerID                                  -- Return data for officer only
        AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) = @StartDate      
--        AND CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,Alarm.EventDisplayTime), 110) = @RunDate
      GROUP BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL(Officer.MiddleName, '') + ' ' + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL(Offender.Middlename, '') + ' ' + Offender.LastName,
               EventType.AbbrevEventType,
               Alarm.EventDisplayTime,
               Alarm.AlarmID       
    END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_MostRecentAlarms] TO db_dml;
GO
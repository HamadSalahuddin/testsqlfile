USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AlarmDetail]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AlarmDetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AlarmDetail.sql
 * Created On: 08/22/2011         
 * Created By: R.Cole  
 * Task #:     #2627
 * Purpose:    Return Data for the AlarmDetail report               
 *
 * Modified By: R.Cole - 12/7/2011: Fixed a bug with Georule
 *                names, per #2977
 *              R.Cole - 02/21/2012:  Substanitially revised
 *              to include support for 'All Agencies' and
 *              'All Officers' per #2677 and #2871
 *              R.Cole - 02/28/2012: Fixed a some issues with
 *                date handling for the All Agencies, All Officers
 *                case.
 *              R.Cole - 03/26/2012: Misc bug fixes.
 *              R.Cole - 06/17/2013: Per #3172, added ability to 
 *              filter down to a single offender.  (User must select
 *              an ageny and an officer first.)
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AlarmDetail] (
  @OfficerID INT,
  @AgencyID INT,
  @DistributorID INT = NULL,
  @RoleID INT = NULL,
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL,
  @OffenderID INT = NULL
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
IF (((@DistributorID IS NOT NULL) AND (@AgencyID = -1)) AND (@OffenderID IS NULL))
  BEGIN
    -- // Get Resultset for All Agencies belonging to Distributor and All Officers // --
    SELECT DISTINCT Alarm.AlarmID,    
           Agency.Agency,
           Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS 'Officer',
           Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS 'Offender',
           EventType.AbbrevEventType AS Alarm,
           CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22) AS AlarmTime,
           dp.PropertyValue AS Device,
           CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END AS GeoRuleName,
--           GeoRule.GeoRuleName,
           AlarmNote.Note,
           @RunDate AS [RunDate],          
           CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
           CONVERT(CHAR(10), @StartDate, 110) AS [EndDate]      -- StartDate and EndDate are the same in this case
    FROM Alarm WITH (NOLOCK)
      INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
      INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
      INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
      INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
      INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
      LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON Alarm.TrackerID = dp.DeviceID AND dp.PropertyID = '8012'
      LEFT OUTER JOIN GeoRule_Offender ON Alarm.OffenderID = GeoRule_Offender.OffenderID
                  AND Alarm.EventParameter = GeoRule_Offender.ZoneID      
      LEFT OUTER JOIN GeoRule ON GeoRule_Offender.GeoRuleID = GeoRule.GeoRuleID
      LEFT OUTER JOIN AlarmNote ON Alarm.AlarmID = AlarmNote.AlarmID
    WHERE Agency.DistributorID = @DistributorID
      AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME)
--      AND DATEADD(MI, @UTCOffset, Alarm.EventDisplayTime) = CONVERT(CHAR(10), @StartDate, 110)  
      AND Agency.Deleted = 0
      AND Officer.Deleted = 0 
    GROUP BY Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
             EventType.AbbrevEventType,
             Alarm.EventDisplayTime,
             Alarm.AlarmID,
             dp.PropertyValue,
             CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END,
             AlarmNote.Note
    ORDER BY Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
             Alarm.AlarmID,
             CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22)
  END
ELSE 
  IF (((@AgencyID > -1) AND (@OfficerID = -1)) AND (@OffenderID IS NULL))
    -- // Get Resultset for Single Agency, All Officers // --
    BEGIN         
      SELECT DISTINCT Alarm.AlarmID,    
             Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS 'Officer',
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS 'Offender',
             EventType.AbbrevEventType AS Alarm,
             CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22) AS AlarmTime,
             dp.PropertyValue AS Device,
             CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END AS GeoRuleName,             
--             GeoRule.GeoRuleName,
             AlarmNote.Note,
             @RunDate AS [RunDate],
             CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
             CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]
      FROM Alarm WITH (NOLOCK)
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
        LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON Alarm.TrackerID = dp.DeviceID AND dp.PropertyID = '8012'
        LEFT OUTER JOIN GeoRule_Offender ON Alarm.OffenderID = GeoRule_Offender.OffenderID
                    AND Alarm.EventParameter = GeoRule_Offender.ZoneID
        LEFT OUTER JOIN GeoRule ON GeoRule_Offender.GeoRuleID = GeoRule.GeoRuleID
        LEFT OUTER JOIN AlarmNote ON Alarm.AlarmID = AlarmNote.AlarmID
      WHERE Agency.AgencyID = @AgencyID 
        AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) BETWEEN CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME) AND CAST(FLOOR(CAST(@EndDate AS FLOAT)) AS DATETIME)           
--        AND DATEADD(MI, @UTCOffset, Alarm.EventDisplayTime) BETWEEN @StartDate AND @EndDate
        AND Officer.Deleted = 0                            
      GROUP BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               EventType.AbbrevEventType,
               Alarm.EventDisplayTime,
               Alarm.AlarmID,
               dp.PropertyValue,
               CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END,
               AlarmNote.Note
      ORDER BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               Alarm.AlarmID,
               CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22)
    END
ELSE 
  IF (((@AgencyID > -1) AND (@OfficerID > -1)) AND (@OffenderID IS NULL))
    BEGIN
      -- // Get Resultset for Single Agency, Single Officer // --
      SELECT DISTINCT Alarm.AlarmID,    
             Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS 'Officer',
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS 'Offender',
             EventType.AbbrevEventType AS Alarm,
             CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22) AS AlarmTime,
             dp.PropertyValue AS Device,
             CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END AS GeoRuleName,
--             GeoRule.GeoRuleName,
             AlarmNote.Note,
             @RunDate AS [RunDate],
             CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
             CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]
      FROM Alarm WITH (NOLOCK)
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
        LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON Alarm.TrackerID = dp.DeviceID AND dp.PropertyID = '8012'
        LEFT OUTER JOIN GeoRule_Offender ON Alarm.OffenderID = GeoRule_Offender.OffenderID
                    AND Alarm.EventParameter = GeoRule_Offender.ZoneID        
        LEFT OUTER JOIN GeoRule ON GeoRule_Offender.GeoRuleID = GeoRule.GeoRuleID
        LEFT OUTER JOIN AlarmNote ON Alarm.AlarmID = AlarmNote.AlarmID
      WHERE Officer.OfficerID = @OfficerID                            
        AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) BETWEEN CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME) AND CAST(FLOOR(CAST(@EndDate AS FLOAT)) AS DATETIME)     
--        AND DATEADD(MI, @UTCOffset, Alarm.EventDisplayTime) BETWEEN @StartDate AND @Enddate    
      GROUP BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               EventType.AbbrevEventType,
               Alarm.EventDisplayTime,
               Alarm.AlarmID,
               dp.PropertyValue,
               CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END,
               AlarmNote.Note
      ORDER BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               Alarm.AlarmID,
               CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22)
    END
ELSE
  IF ((@AgencyID > -1 AND (@OfficerID > -1)) AND (@OffenderID > -1))
    BEGIN
      -- // Get Resultset for Single Agency, Single Officer, Single Offender // --
      SELECT DISTINCT Alarm.AlarmID,    
             Agency.Agency,
             Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName AS 'Officer',
             Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName AS 'Offender',
             EventType.AbbrevEventType AS Alarm,
             CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22) AS AlarmTime,
             dp.PropertyValue AS Device,
             CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END AS GeoRuleName,
--             GeoRule.GeoRuleName,
             AlarmNote.Note,
             @RunDate AS [RunDate],
             CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
             CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]
      FROM Alarm WITH (NOLOCK)
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Officer.AgencyID = Agency.AgencyID
        LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON Alarm.TrackerID = dp.DeviceID AND dp.PropertyID = '8012'
        LEFT OUTER JOIN GeoRule_Offender ON Alarm.OffenderID = GeoRule_Offender.OffenderID
                    AND Alarm.EventParameter = GeoRule_Offender.ZoneID        
        LEFT OUTER JOIN GeoRule ON GeoRule_Offender.GeoRuleID = GeoRule.GeoRuleID
        LEFT OUTER JOIN AlarmNote ON Alarm.AlarmID = AlarmNote.AlarmID
      WHERE Offender.OffenderID = @OffenderID                            
        AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset,Alarm.EventDisplayTime) AS FLOAT)) AS DATETIME) BETWEEN CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME) AND CAST(FLOOR(CAST(@EndDate AS FLOAT)) AS DATETIME)     
--        AND DATEADD(MI, @UTCOffset, Alarm.EventDisplayTime) BETWEEN @StartDate AND @Enddate    
      GROUP BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               EventType.AbbrevEventType,
               Alarm.EventDisplayTime,
               Alarm.AlarmID,
               dp.PropertyValue,
               CASE WHEN Alarm.EventTypeID IN (36,37,44,45) THEN GeoRule.GeoRuleName ELSE '' END,
               AlarmNote.Note
      ORDER BY Agency.Agency,
               Officer.FirstName + ' ' + ISNULL((CASE Officer.MiddleName WHEN '' THEN NULL ELSE Officer.MiddleName + ' ' END), '') + Officer.LastName,
               Offender.FirstName + ' ' + ISNULL((CASE Offender.MiddleName WHEN '' THEN NULL ELSE Offender.MiddleName + ' ' END), '') + Offender.LastName,
               Alarm.AlarmID,
               CONVERT(CHAR(20), DATEADD(mi, @UTCOffset, Alarm.EventDisplayTime), 22)
    END 
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AlarmDetail] TO db_dml;
GO
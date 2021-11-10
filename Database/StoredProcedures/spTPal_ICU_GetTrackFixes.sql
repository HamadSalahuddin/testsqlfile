USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_ICU_GetTrackFixes]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_ICU_GetTrackFixes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   [spTPal_ICU_GetTracks].sql
 * Created On: 3/6/2015
 * Created By: R.Cole
 * Task #:     ICU integration
 * Purpose:    Get the events for an offender for the last 24 hours              
 *
 * TODO: Use a view?  
 *       Revamp existing but unused EventsBucket view to use an index?
 *       Correct for Local agency time and DST?
 *       Remove EventID from FixType, that's a debugging tool only.
 * 
 * Modified By: R.Cole - 3/23/2015: Added @StartDate & @EndDate Params,
 *         Changed FixType, Added code for Description, LOI and IconName
 *              R.Cole - 3/24/2015: Added new FixType for non-comm related alarms
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_ICU_GetTrackFixes] (
  @OffenderID INT,
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // TO DO: Account for an Agency's UTC offset and DST changes. Start/End time below is the quick hack version for last 24 hours

-- // Account for NULL Date Params // --
IF ((@StartDate IS NULL) OR (@EndDate IS NULL))
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, GETDATE())
    SET @EndDate = GETDATE()
  END   
   
-- // Main Query // --
SELECT b1.EventPrimaryID AS [UniqueID],
       b1.EventDateTime AS [EventDateTime],
       b1.Latitude AS [Latitude],
       b1.Longitude AS [Longitude],
--       b1.EventID AS [FixType],                     -- ***** EventID is here for Debugging ONLY, will be removed ****
       (CASE WHEN b1.EventID = 0 THEN 'F' 
             WHEN b1.EventID IN (256,257,258) THEN 'X'
             ELSE 'E' 
       END) AS [FixType],
       b1.OffenderName AS [OffenderName],
       g2.[Description] AS [Description],
       g2.[LevelOfInterest] AS [LevelOfInterest],
       (CASE WHEN b1.GpsValid = 1 AND b1.GpsValidSatellites = 1 THEN 50         -- High Confidence
             WHEN b1.GpsValid = 0 AND b1.GpsValidSatellites = 1 THEN 500        -- Medium Confidence
             WHEN b1.GpsValid = 1 AND b1.GpsValidSatellites = 0 THEN 500        -- Medium Confidence
             WHEN b1.GpsValid = 0 AND b1.GpsValidSatellites = 0 THEN -1         -- Low/Invalid
       END) AS [Accuracy],
       gwEvt.Hdop AS [Hdop],
       gwEvt.Speed AS [Speed],
       g2.[IconName] AS [IconName]
FROM rprtEventsBucket1 b1
  INNER JOIN Gateway.dbo.Events gwEvt ON b1.DeviceID = gwEvt.DeviceID
         AND b1.EventTime = gwEvt.EventTime
         AND b1.EventID = gwEvt.EventID
  INNER JOIN G2EventTransformation g2 ON b1.EventID = g2.EventTypeID
WHERE OffenderID = @OffenderID
  AND EventDateTime BETWEEN @StartDate AND @EndDate
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_ICU_GetTrackFixes] TO db_dml;
GO
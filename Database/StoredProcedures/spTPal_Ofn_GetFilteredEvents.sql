USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetFilteredEvents]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetFilteredEvents]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetFilteredEvents.sql
 * Created On: 3/22/2011
 * Created By: R.Cole
 * Task #:     #1311
 * Purpose:    Return OffenderIDs meeting a user selected event 
 *             filter criteria
 *
 * Modified By: R.Cole - 3/29/2011: Modified to add FilterType 2
 *              NOTE FilterType 2 returns the OffenderID AND
 *              the event status of the latest event.
 *              R.Cole - 4/18/2011: Modified to ensure we are
 *              returning the status of the correct event for
 *              the HasActiveAlarms filter (2)
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetFilteredEvents] (
  @OffenderIDs VARCHAR(MAX),
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL,
  @CenterPointLat FLOAT = 0,
  @CenterPointLong FLOAT = 0,
  @Radius FLOAT = 0,
  @FilterType INT
) 
AS
/* **************** Dev Notes ***********************
OffenderFilter Enum
------------------------
TrackerEvents = @FilterType: 0  -- EventID 0,48
Alarms                          -- EventID 5,21,25,26,36,37,44,46,65,132,133,177,178,179,182,210,211,212,219,220,256,257,258,280,281,282
ActiveAlarms                    -- EventID same as above, return the status of the latest event for parsing on the client.
InclusionViolations             -- EventID 44,45,194,195
ExclusionViolations             -- EventID 36,37
StrapAlarms                     -- EventID 65 
CommunicationEvents             -- EventID 256,257,258
PowerEvents                     -- EventID 1,209,210,211,212,216,217,218
GPSEvents = @FilterType: 8      -- EventID 132,133,219,220
 * ******************* End Dev Notes ***************************** */

-- // Handle NULL Dates (default to last 6 hours if either date param is NULL) // --
IF (@StartDate IS NULL OR @EndDate IS NULL)
  BEGIN
    SET @StartDate = DATEADD(HOUR, -6, GETDATE()) 
    SET @EndDate = GETDATE()
  END

-- // Parse Offenders // --
SELECT [number]
INTO #tmpOffenderIDs
FROM GetTableFromListId(@OffenderIDs)

-- // Index offenderid temp table // --
CREATE CLUSTERED INDEX #xpktmpOffender ON #tmpOffenderIDs(number)

-- // Main Query // --
IF @FilterType = 2        -- HasActiveAlarms 
  BEGIN    
    SELECT DISTINCT Bucket1.OffenderID,
           gwEvents.[Status]
    FROM rprtEventsBucket1 (NOLOCK) Bucket1
      INNER JOIN #tmpOffenderIDs tmpoff ON Bucket1.OffenderID = tmpoff.number
      LEFT OUTER JOIN Gateway.dbo.[Events] (NOLOCK) gwEvents ON gwEvents.DeviceID = Bucket1.DeviceID
                                                             AND gwEvents.EventID = Bucket1.EventID
                                                             AND gwEvents.EventTime = Bucket1.EventTime
    WHERE (Bucket1.EventDateTime BETWEEN @StartDate AND @EndDate)
      AND (@Radius = 0 OR [dbo].[GetDistance] (@CenterPointLat,@CenterPointLong, Bucket1.Latitude, Bucket1.Longitude) <= @Radius)
      AND Bucket1.EventTime = (SELECT MAX(EventTime)
                               FROM rprtEventsBucket1 (NOLOCK) b1 
                               WHERE b1.OffenderID = tmpoff.number
                                 AND (b1.EventDateTime BETWEEN @StartDate AND @EndDate))
      AND gwEvents.[Status] <> 0
  END
ELSE                      -- All other filters 
  BEGIN
    SELECT DISTINCT Bucket1.OffenderID
    FROM rprtEventsBucket1 (NOLOCK) Bucket1
	    INNER JOIN #tmpOffenderIDs tmpoff ON Bucket1.OffenderID = tmpoff.number
      INNER JOIN OffenderFilters ON Bucket1.EventID = OffenderFilters.EventID
    WHERE	(Bucket1.EventDateTime BETWEEN @StartDate AND @EndDate)
      AND OffenderFilters.OffenderFilterTypeID = @FilterType                 
	    AND (@Radius = 0 OR [dbo].[GetDistance] (@CenterPointLat,@CenterPointLong, Bucket1.Latitude, Bucket1.Longitude) <= @Radius)

    UNION ALL    

    SELECT DISTINCT Bucket2.OffenderID
    FROM rprtEventsBucket2 (NOLOCK) Bucket2
      INNER JOIN #tmpOffenderIDs tmpoff ON Bucket2.OffenderID = tmpoff.number
      INNER JOIN OffenderFilters ON Bucket2.EventID = OffenderFilters.EventID
    WHERE (Bucket2.EventDateTime BETWEEN @StartDate AND @EndDate)
      AND OffenderFilters.OffenderFilterTypeID = @FilterType                 
      AND (@Radius = 0 OR [dbo].[GetDistance] (@CenterPointLat, @CenterPointLong, Bucket2.Latitude, Bucket2.Longitude) <= @Radius)
  END	
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetFilteredEvents] TO db_dml;
GO
USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OffenderGetTraces]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OffenderGetTraces]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 2-Mar-2010
-- Description:	This procedure gets list of all event traces between given dates for
-- provided Offender if that traces have been with the area of given radius.
-- =============================================
CREATE PROCEDURE [dbo].[OffenderGetTraces] (
	@StartDate DateTime,
	@EndDate DateTime,
	@EventTypeID DateTime,
	@OffenderID int,
	@CenterPointlat float,
	@CenterPointlong float,
	@radius float
)	 
AS
BEGIN
	SET NOCOUNT ON;
   
	SELECT * FROM(
		SELECT DeviceID,
        TrackerNumber,
        EventDateTime,
        EventID,
        AlarmType,
        AlarmAssignmentStatusName,
        Longitude,
        Latitude,
        [Address],
        OffenderID,
        AlarmID,
        GpsValid,
        GpsValidSatellites,
        GeoRule,
        SO,
        OPR,
        EventTypeGroupID,
        OffenderName,
        OffenderDeleted        
    FROM rprtEventsBucket1
    WHERE EventDateTime BETWEEN @StartDate AND @EndDate 
	AND 
		OffenderID = @OffenderID
)tempT WHERE  [dbo].[GetDistance] (@CenterPointlat,@CenterPointlong,
tempT.Latitude,tempT.Longitude) <= @radius AND @radius <> 0

AND  ((@EventTypeID < 0 ) OR (EventID = @EventTypeID))

END

GO

GRANT EXECUTE ON [dbo].[OffenderGetTraces] TO db_dml;
GO

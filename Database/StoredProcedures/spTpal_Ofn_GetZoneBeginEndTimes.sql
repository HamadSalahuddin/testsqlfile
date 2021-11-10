USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTpal_Ofn_GetZoneBeginEndTimes]    Script Date: 08/10/2016 06:18:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 ALTER PROC [dbo].[spTpal_Ofn_GetZoneBeginEndTimes]
 	@OffenderID	INT,
	@ZoneID INT,
	@AlarmDateTime DATETIME,
	@StartDateTime DATETIME OUTPUT,
	@EndDateTime DATETIME OUTPUT,
	@GeoRuleID INT = NULL
/*
Proc: spTpal_Ofn_GetZoneBeginEndTimes
Author: David Riding
Log:
Modified by: DRiding 12/19/16  - When backtracking to previous week to find zone start time, once it got to Saturday (dayofweek 7) it wouldn't go earlier than 7, so it got into an endless loop. 
								Also, return datetimes for Start and End, not times of day, which didn't take into account going to a previous do or to a next day.

test:
	DECLARE @startdatetime datetime, @enddatetime datetime
	EXEC spTpal_Ofn_GetZoneBeginEndTimes @OffenderID = 188, @ZoneID = 3, @AlarmDateTime = '12/18/16 07:59' , @startdatetime = @startdatetime output, @enddatetime = @enddatetime output

	select @startdatetime, @enddatetime



*/
AS

declare --@GeoRuleID int,
 @AreaID int, @GeoRuleTypeID int, 
	@nowminute int, @nowdw int, @lastminute int, @lastminutetemp int, 
	@AlarmDateTimeone bit, @addday int, @startdate datetime, @enddate datetime, @checkdw int , @AlwaysON bit, @diffday int


--Get georule information based on offender and zone
IF @GeoRuleID IS NULL
SELECT @GeoRuleID = GeoRule.GeoRuleID, 
		@AreaID = GeoRule_Offender.AreaID,
		@GeoRuleTypeID = GeoRule.GeoRuleTypeID
			FROM GeoRule WITH (NOLOCK)
			  INNER JOIN GeoRule_Offender ON GeoRule.GeoRuleID = GeoRule_Offender.GeoRuleID
			  WHERE OffenderID = @OffenderID
				AND GeoRule_Offender.ZoneID = @ZoneID

ELSE
BEGIN
SELECT  @AreaID = GeoRule_Offender.AreaID,
		@GeoRuleTypeID = GeoRule.GeoRuleTypeID
			FROM GeoRule WITH (NOLOCK)
			  INNER JOIN GeoRule_Offender ON GeoRule.GeoRuleID = GeoRule_Offender.GeoRuleID
			  WHERE OffenderID = @OffenderID
				AND GeoRule_Offender.GeoRuleID = @GeoRuleID

END

--get all rules for this Zone (Zone indicated by @AreaID) and GeoRule type.
SELECT 
	GeoRule.GeoRuleID, 
    go2.AreaID,
    GeoRule.StatusID,
	GeoRule.GeoRuleTypeID,
	Schedule.AlwaysOn, 
	Schedule.StartTime, 
	Schedule.EndTime, 
	Schedule.Sunday, 
	Schedule.Monday, 
	Schedule.Tuesday,
	Schedule.Wednesday, 
	Schedule.Thursday, 
	Schedule.Friday, 
	Schedule.Saturday 
INTO #rules
FROM GeoRule_Offender go2 
		INNER JOIN GeoRule ON GeoRule.GeoRuleID = go2.GeoRuleID 
		INNER JOIN GeoRuleSchedule schedule ON schedule.GeoRuleScheduleID = GeoRule.GeoRuleScheduleID
 WHERE go2.OffenderID = @OffenderID 
		AND go2.AreaID = @AreaID
		AND GeoRule.GeoRuleTypeID = @GeoRuleTypeID
		
ORDER BY Schedule.StartTime

if EXISTS (SELECT 1 FROM #rules where AlwaysON = 1) BEGIN
	SET @AlwaysON = 1
END
ELSE BEGIN
SET @AlwaysON = 0 




--put schedule into temp table - one row for each time period/day combo
select  * INTO #detailed_schedule 
	from (
SELECT GeoRuleID, starttime, Endtime, 1 ruleday FROM #rules where Sunday = 1
UNION 
SELECT GeoRuleID, starttime, Endtime, 2 FROM #rules where Monday = 1
UNION 
SELECT GeoRuleID, starttime, Endtime, 3 FROM #rules where Tuesday = 1
UNION 
SELECT GeoRuleID, starttime, Endtime, 4 FROM #rules where Wednesday = 1
UNION 
SELECT GeoRuleID, starttime, Endtime, 5 FROM #rules where Thursday = 1
UNION 
SELECT GeoRuleID, starttime, Endtime, 6 FROM #rules where Friday = 1
UNION 
SELECT GeoRuleID, starttime, Endtime,  7 FROM #rules where Saturday = 1 --AND starttime < endtime

) d

order by d.ruleday, d.starttime

--Split the schedules that go from one day to the next into 2 
--1 - the beginning of the next day
INSERT INTO #detailed_schedule (georuleid, starttime, endtime, ruleday)
SELECT georuleid, 0, endtime, CASE WHEN ruleday = 7 THEN 1 ELSE ruleday + 1 END from #detailed_schedule  where endtime < starttime 
--2- the end of the originalda
UPDATE #detailed_schedule set endtime = 1439 WHERE  endtime < starttime 




--find end of schedule - step through subsequent rules until there is a time without 
SELECT @nowdw = datepart(dw, @AlarmDateTime)
SET @addday = 0
SET @diffday = 0 
SELECT @nowminute = datepart(hh, @AlarmDateTime) * 60  + datepart(n, @AlarmDateTime)
select  @lastminutetemp = @nowminute, @lastminute = @nowminute

WHILE @lastminutetemp IS NOT NULL 
BEGIN
	
	select @lastminutetemp = NULL 
	SELECT @checkdw = @nowdw + @addday - CASE WHEN @nowdw + @addday > 7 THEN 7 ELSE 0 END 
	SELECT @lastminutetemp = endtime from #detailed_schedule WHERE @lastminute >= starttime AND @lastminute <= endtime AND ruleday = @checkdw 
	IF @lastminutetemp IS NOT NULL bEGIN 
		SET @lastminute = @lastminutetemp + 1
		
		IF @lastminute = 1440 BEGIN
			SET @addday = @addday + 1
			SET @diffday = @diffday + 1
			SET @lastminute = 0 
		END

	END
END



SET @enddate = DATEADD(ss, -DATEPART(ss, @AlarmDateTime),  --remove seconds
					DATEADD(n, (@diffday * 1440) + @lastminute - @nowminute, @AlarmDateTime) --get end of current curfew
				)

if @enddate = @AlarmDateTime BEGIN
	SET @enddate = NULL 
END
ELSE BEGIN


	select  @lastminutetemp = @nowminute, @lastminute = @nowminute
	SET @addday = 0
	SET @diffday = 0 
	WHILE @lastminutetemp IS NOT NULL 
	BEGIN
	
		select @lastminutetemp = NULL 
		SELECT @checkdw = @nowdw + @addday 
		IF @checkdw < 1 BEGIN
			SET @checkdw = 7
			SET @addday = 7 - @nowdw  --DR121916 Previously it was just setting @addday to 7, and not updating @checkdw in this block, so it got stuck on 7 and caused an infinite loop
		END

		SELECT @lastminutetemp = starttime from #detailed_schedule WHERE @lastminute >= starttime AND @lastminute <= endtime AND ruleday = @checkdw 
		IF @lastminutetemp IS NOT NULL bEGIN 
			SET @lastminute = @lastminutetemp - 1
		
			IF @lastminute = -1 BEGIN
				SET @addday = @addday - 1
				SET @diffday = @diffday - 1
				SET @lastminute = 1439 
			END

		END
	END

	SET @lastminute = @lastminute + 1


	SET @startdate = DATEADD(ss, -DATEPART(ss, @AlarmDateTime), --remove seconds
							DATEADD(n, (@diffday * 1440) + @lastminute - @nowminute, @AlarmDateTime)  --get beginning of current curfew
							)

END 

END


--SELECT @startdate AS ActualScheduleStart, @enddate as ActualScheduleEnd, @GeoRuleID as GeoRuleID, @GeoRuleTypeID AS GeoRuleTypeID , @AlwaysON as AlwaysOn
--SELECT @StartTime = DATEDIFF(MINUTE, DATEADD(DAY, DATEDIFF(DAY, 0, @startdate), 0), @startdate),
--	@EndTime = DATEDIFF(MINUTE, DATEADD(DAY, DATEDIFF(DAY, 0, @enddate), 0), @enddate)


SELECT @StartDateTime = @startdate, @EndDateTime = @enddate




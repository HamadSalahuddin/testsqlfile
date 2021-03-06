USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetGrace]    Script Date: 08/10/2016 06:55:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetGrace.sql
 * Created On: 09/20/2013         
 * Created By: SABBASI  
 * Task #:     N/A
 * Purpose:    Grace Project. Get Grace Period for the offender currently active.               
 *
 * Modified By: SABBASI - 10/24/2013
 * Modified Reason: Grace would be processed based on two values GraceLate and GraceEarly.
 *              R.Cole - 12/11/2014: Revised for readability, removed single character
 *              aliases.
 * Modified BY: SABASI - 05/05/2016
 * Modified Reason: Bug #10091; Added Sproc "spTpal_Ofn_GetZoneBeginEndTimes" to find if the 
 * schedule continues to next zone
 * Modified By: DRiding 12/19/16 - modified to work with updated version of spTpal_Ofn_GetZoneBeginEndTimes that returns actual datetimes for grace end and grace start instead of times of day.
 * EXEC [spTPal_Ofn_GetGrace] 188, 11165,  '12/19/16 17:36' 
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetGrace] (
	@OffenderID	INT,
	@GeoRule INT,
	@AlarmDateTime DATETIME
)
AS
BEGIN	
	SET NOCOUNT ON;

  DECLARE @AlarmTime INT,
          @schedule_start_time INT, 
          @schedule_end_time INT, 
          @grace_schedule_start DATETIME, 
          @grace_schedule_end DATETIME,
          @grace_early INT, 
          @grace_late INT, 
          @GraceLateAlarm BIT , 
          @AlarmDefused BIT 
          
  SET @GraceLateAlarm = 0
  SET @AlarmDefused = 0

  SELECT @AlarmTime = DATEDIFF(MINUTE, DATEADD(DAY, DATEDIFF(DAY, 0, @AlarmDateTime), 0), @AlarmDateTime)

  SELECT @schedule_start_time = grs.startTime, 
         @schedule_end_time = grs.endTime,
         @grace_early = Grace.GraceEarly, 
         @grace_late = Grace.GraceLate
  FROM GeoRule gr
    INNER JOIN GeoRuleSchedule grs ON grs.GeoRuleScheduleID = gr.GeoRuleScheduleID
    INNER JOIN GeoRule_Offender gro ON gro.GeoRuleID = gr.GeoRuleID 
    INNER JOIN Grace ON gro.GraceID = Grace.GraceID
  WHERE gr.GeoRuleID = @GeoRule

-- Dave's Sproc
-- ////////////////////////////////////
DECLARE @startDT DATETIME, @endDT DATETIME
Exec spTpal_Ofn_GetZoneBeginEndTimes @OffenderID , NULL, @AlarmDateTime,@startDT output, @endDT output,@GeoRule
IF  @startDT IS NULL BEGIN
	SET @startDT = DATEADD(mi, @schedule_start_time, Convert(DATETIME, CONVERT(varchar, @AlarmDateTime, 101)))
END

IF @endDT IS NULL
BEGIN
	SET @endDT = DATEADD(mi, @schedule_end_time, Convert(DATETIME, CONVERT(varchar, getdate(), 101)))
	IF @schedule_end_time < @schedule_start_time  SET @endDT = DATEADD(dd, 1, @endDT)
END

-- ////////////////////////
    -- // Set grace schedule start time and grace schedule end time by adding grace value in the original time. //--
	SET @grace_schedule_start = DATEADD(mi, @grace_late, @startDT)
	SET @grace_schedule_end = DATEADD(mi, -@grace_early, @endDT)
	
  -- // Alarm occurred but AlarmTime is less than schedule start which is original start time + grace // --
	IF @AlarmDateTime <  @grace_schedule_start And @AlarmDateTime >= @startDT
    BEGIN
	    SET @GraceLateAlarm = 1
	    SET @AlarmDefused = 1

    -- // Calculate late grace expiry date so that alarm could be raised again once the grace is over without any compliance. // --
	    DECLARE @day DateTIme, 
	            @ExpiryDate DateTime
	            
		  --SET @day = DATEADD(d, 0, DATEDIFF(d, 0, @AlarmDateTime))
		  SET @ExpiryDate = @grace_schedule_start -- DATEADD(mi,@grace_schedule_start,@day)

    END
	ELSE IF @AlarmDateTime >  @grace_schedule_end AND @AlarmDateTime <= @endDT -- Alarm occured but it is within late grace.
    BEGIN
	    SET @AlarmDefused = 1 
    END

  -- // Get information about whether alarm is defused or not, Is Late Alarm and when the late grace will expire. // --
  SELECT @GraceLateAlarm AS "GraceLateAlarm", 
         @AlarmDefused AS "AlarmDefused", 
         @ExpiryDate AS "ExpiryDate"
END

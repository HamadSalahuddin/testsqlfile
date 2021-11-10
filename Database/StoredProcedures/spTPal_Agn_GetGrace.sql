USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Agn_GetGrace]    Script Date: 08/10/2016 06:50:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Agn_GetGrace.sql
 * Created On: 10/29/2014         
 * Created By: SABBASI  
 * Task #:     3474
 * Purpose:    Grace Project. Get Grace Period settings of the agency.               
 *
 * Modified By: R.Cole - 12/11/2014
 * Modified Reason: Readability and removed aliases using the reserved 
 *                  word "go"
 * Modified BY: SABASI - 05/05/2016
 * Modified Reason: Bug #10091; Added Sproc "spTpal_Ofn_GetZoneBeginEndTimes" to find if the 
 * schedule continues to next zone
 * Modified By: DRiding 12/19/16 - modified to work with updated version of spTpal_Ofn_GetZoneBeginEndTimes that returns actual datetimes for grace end and grace start instead of times of day.
 * EXEC [spTPal_Agn_GetGrace] 188, 3,  '12/20/16 11:55' 
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Agn_GetGrace] (
	@OffenderID	INT,
	@ZoneID INT,
	@AlarmDateTime DATETIME
)
AS
BEGIN

	DECLARE @AlarmTime INT,
	        @schedule_start_time INT, 
	        @schedule_end_time INT, 
	        @grace_schedule_start DATETIME, 
			    @grace_schedule_end DATETIME,
			    @grace_early INT, 
			    @grace_late INT, 
			    @GraceLateAlarm BIT , 
			    @AlarmDefused BIT, 
			    @EnableOfficerGrace BIT,
			    @Offender_GraceEarly INT, 
			    @Offender_GraceLate INT,
			    @GeoRule INT

	SET @GraceLateAlarm = 0
	SET @AlarmDefused = 0

	SELECT @AlarmTime = DATEDIFF(MINUTE, DATEADD(DAY, DATEDIFF(DAY, 0, @AlarmDateTime), 0), @AlarmDateTime)
	
	EXEC mGeoRuleGetByOffenderIDZoneID @OffenderID,@ZoneID,@GeoRule OUTPUT

	SELECT @schedule_start_time = grs.startTime, 
	       @schedule_end_time = grs.endTime,
	       @grace_early = Agency.GraceEarly, 
	       @grace_late = Agency.GraceLate, 
	       @EnableOfficerGrace = Agency.GraceEnable
	FROM GeoRule 
	  INNER JOIN GeoRuleSchedule grs ON grs.GeoRuleScheduleID = GeoRule.GeoRuleScheduleID
	  INNER JOIN GeoRule_Offender gro ON gro.GeoRuleID = GeoRule.GeoRuleID 
	  INNER JOIN Offender ON gro.OffenderID = Offender.OffenderID
	  INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
	WHERE GeoRule.GeoRuleID = @GeoRule


-- /////////////////////////
-- Dave's SProc	
DECLARE @startDT DATETIME, @endDT DATETIME
Exec spTpal_Ofn_GetZoneBeginEndTimes @OffenderID , @ZoneID, @AlarmDateTime,@startDT output, @endDT output,@GeoRule
IF  @startDT IS NULL BEGIN
	SET @startDT = DATEADD(mi, @schedule_start_time, Convert(DATETIME, CONVERT(varchar, @AlarmDateTime, 101)))
END

IF @endDT IS NULL
BEGIN
	SET @endDT = DATEADD(mi, @schedule_end_time, Convert(DATETIME, CONVERT(varchar, getdate(), 101)))
	IF @schedule_end_time < @schedule_start_time  SET @endDT = DATEADD(dd, 1, @endDT)
END


-- /////////////////////////
	-- // Set grace schedule start time and grace schedule end time by adding grace value in the original time. // --
	SET @grace_schedule_start = DATEADD(mi, @grace_late, @startDT)
	SET @grace_schedule_end = DATEADD(mi, -@grace_early, @endDT)
	
	-- // Alarm occurred but AlarmTime is less than schedule start which is original start time + grace // --
	IF @AlarmDateTime <  @grace_schedule_start And @AlarmDateTime >= @startDT
	  BEGIN
		  SET @GraceLateAlarm = 1
		  SET @AlarmDefused = 1
	
	    -- // Calculate late grace expiry date so that alarm could be raised again once the grace is over without any compliance. // --
		  DECLARE @day DateTIme, @ExpiryDate DateTime
		
		  --SET @day = DATEADD(d, 0, DATEDIFF(d, 0, @AlarmDateTime))
		  SET @ExpiryDate = @grace_schedule_start -- DATEADD(mi,@grace_schedule_start,@day)
		 
	  END
	ELSE IF @AlarmDateTime >  @grace_schedule_end AND @AlarmDateTime <= @endDT -- Alarm occured but it is within late grace.
	  BEGIN
		  SET @AlarmDefused = 1 
	  END
	
	SELECT @Offender_GraceEarly = Grace.graceearly, 
	       @Offender_GraceLate = Grace.gracelate
	FROM GeoRule 
	  INNER JOIN GeoRule_Offender gro ON gro.GeoRuleID = GeoRule.GeoRuleID 
	  INNER JOIN Grace ON gro.GraceID = Grace.GraceID
	WHERE GeoRule.GeoRuleID = @GeoRule
	
  -- // Get information about whether alarm is defused or not, Is Late Alarm and when the late grace will expire. // --
	SELECT @GraceLateAlarm AS "GraceLateAlarm", 
	       @AlarmDefused AS "AlarmDefused", 
	       @ExpiryDate AS "ExpiryDate", 
	       @EnableOfficerGrace AS "EnableOfficerGrace", 
	       @GeoRule AS "GeoRule",
	       @Offender_GraceEarly AS "Offender_GraceEarly", 
	       @Offender_GraceLate AS "Offender_GraceLate"
END

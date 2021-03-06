USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_MonitorGracePeriodAlarm]    Script Date: 03/25/2016 10:07:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_MonitorGracePeriodAlarm.sql
 * Created On: 09/26/2013         
 * Created By: SABBASI  
 * Task #:     N/A
 * Purpose:    Grace Project - to get list of alarms that have not met with compliance after grace expires.           
 *
 * Modified By: R.Cole - 12/11/2014: Readability changes
 *              Sahib  - 02/13/2016: Added ExpiryDate to Select statement we need it in the app
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_MonitorGracePeriodAlarm] 
AS
BEGIN	
	DECLARE @current_dt datetime 
	
	SET @current_dt = getdate()
	
	SELECT GracePeriodAlarmID, 
	       AlarmID,OffenderID,ExpiryDate, 
	       [Message] AS "Message" FROM GracePeriodAlarm
	WHERE Deleted <> 1	
	  AND (ExpiryDate < @current_dt)
	
	IF @@ROWCOUNT > 0 
	  BEGIN
		  UPDATE GracePeriodAlarm 
		    SET Deleted = 1 
		    WHERE Deleted <> 1 AND (ExpiryDate < @current_dt)
	  END
END


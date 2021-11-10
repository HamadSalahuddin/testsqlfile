USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Alm_UpdateSuspendedAlarms]    Script Date: 11/26/2010 11:29:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   SPTPal_Alm_UpdateSuspendedAlarms.sql
 * Created On: 28-Sept-2010
 * Created By: S.Abbasi
 * Task #:     #541
 * Purpose:    This procedure updates GeoRuleIDs which is represented GeoZonesIDs in 
 *    AlarmAlarmSuspended table after the GeoRuleIDs in GeoRule table have been updated either
 *    because of reupload/save of GeoRule or DayLight Savings adjustment.               
 *
 * Modified By: R.Cole - 09/29/2010 - Added IF EXISTS and
 *                GRANT Stmts.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Alm_UpdateSuspendedAlarms] (
	@AlarmSuspendedID Bigint,
	@ZoneIDs Varchar(50)	
)
AS
BEGIN
	UPDATE AlarmSuspended
	  SET ZoneIDs = @ZoneIDs
	  WHERE AlarmSuspendedID = @AlarmSuspendedID
END

USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[OffenderGetLastAlarmExcludingPrivateAlarms]    Script Date: 02/03/2016 06:30:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetLastNonPrivateAlarm.sql
 * Created On: 2/3/2016
 * Created By: Sohail
 * Task #:     #9414       
 * Purpose:    Preventing private alarms from displaying on home screen for Non App Admin Users
 *
 * ******************************************************** */
CREATE Procedure [dbo].[spTPal_Ofn_GetLastNonPrivateAlarm]

	@OffenderID	INT

AS
	SELECT	top 1 * FROM  Alarm a INNER JOIN EventType et ON et.EventTypeID=a.EventTypeID
	WHERE a.OffenderID=@OffenderID AND isPrivate=0 ORDER BY a.eventtime desc
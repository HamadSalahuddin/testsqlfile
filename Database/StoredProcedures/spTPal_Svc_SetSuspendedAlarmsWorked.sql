USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Svc_SetSuspendedAlarmsWorked]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Svc_SetSuspendedAlarmsWorked]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Svc_SetSuspendedAlarmsWorked.sql
 * Created On: 02-Oct-2012         
 * Created By: SABBASI  
 * Task #:     Redmine #3434
 * Purpose:    Update the suspended alarms which are worked.
 *
 * Modified By: R.Cole - 10/08/2012: Added missing DROP AND 
 *              GRANT statements.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Svc_SetSuspendedAlarmsWorked] (
	@SuspendedAlarmsWorked VARCHAR(MAX),
	@AlarmActive BIT = 0
)
AS
SET NOCOUNT ON;

BEGIN
	UPDATE TrackerPal.dbo.AlarmSuspended
	  SET AlarmActive = @AlarmActive
	WHERE AlarmSuspendedID in (SELECT number FROM GetTableFromListId( @SuspendedAlarmsWorked ) )
END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Svc_SetSuspendedAlarmsWorked] TO db_dml;
GO
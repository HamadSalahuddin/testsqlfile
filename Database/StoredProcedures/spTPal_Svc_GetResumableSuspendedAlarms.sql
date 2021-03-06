USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Svc_GetResumableSuspendedAlarms]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Svc_GetResumableSuspendedAlarms]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Svc_GetResumableSuspendedAlarms.sql
 * Created On: 02-Oct-2012         
 * Created By: SABBASI  
 * Task #:     Redmine #3434    
 * Purpose:    Get list of Alarms that are suspended and for 
 *             which there was an alarm raised which was 
 *             eaten up by alarm service because of suspension.               
 *
 * Modified By: R.Cole - 10/08/2012: Added missing DROP AND 
 *              GRANT statements.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Svc_GetResumableSuspendedAlarms] (
	@CurrentTime DATETIME = NULL
)
AS
BEGIN
	IF @CurrentTime IS NULL 
    SET @CurrentTime = GETDATE()

	SELECT AlarmSuspendedID,
         OffenderID 
  FROM TrackerPal.dbo.AlarmSuspended
	WHERE (EndTime <=  @CurrentTime AND AlarmActive = 1)
END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Svc_GetResumableSuspendedAlarms] TO db_dml;
GO
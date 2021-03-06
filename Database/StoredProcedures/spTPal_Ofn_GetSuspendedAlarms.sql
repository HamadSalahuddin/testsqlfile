USE [TrackerPal]
GO

IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetSuspendedAlarms]') AND [type]='P'))
  DROP PROCEDURE [dbo].[spTPal_Ofn_GetSuspendedAlarms]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		  Sajid Abbasi>
-- Create date: 28-Sept-2010>
-- Description:	This stored procedure gets list of
--    suspended Alarms with in the given parameter list
-- =============================================
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetSuspendedAlarms] (
	@AgencyID int,
	@OfficerID int,
	@OffenderID int 
)
AS
BEGIN
	SELECT AlarmSuspendedID,
	       AgencyID,
	       OfficerID,
	       OffenderID,
	       RequestingOfficerID,
	       AlarmProtocolEventID,
	       StartTime,
	       EndTime,
	       CreatedDate,
	       CreatedBy,
	       ConfirmationNumber,
	       Deleted,
	       ZoneIDs 
	FROM AlarmSuspended
	WHERE AgencyID = @AgencyID 
	  AND OfficerID = @OfficerID 
	  AND OffenderID = @OffenderID
	  AND EndTime <= GETDATE()
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetSuspendedAlarms] TO db_dml;  
GO
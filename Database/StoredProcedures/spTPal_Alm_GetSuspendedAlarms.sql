USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Alm_GetSuspendedAlarms]    Script Date: 11/26/2010 15:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Alm_GetSuspendedAlarms.sql
 * Created On: 28-Sept-2010
 * Created By: S.Abbasi
 * Task #:     #541
 * Purpose:    This stored procedure gets list of suspended 
 *             Alarms with in the given parameter list               
 *
 * Modified By: R.Cole - 09/29/2010 - Removed SELECT *, added
 *        IF EXISTS and GRANT Stmts.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Alm_GetSuspendedAlarms] (
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
	WHERE	AgencyID = @AgencyID 
	  AND OfficerID= @OfficerID 
	  AND OffenderID = @OffenderID
	  AND Deleted = 0
	  AND EndTime >= GETDATE()
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Alm_GetSuspendedAlarms] TO db_dml;
GO
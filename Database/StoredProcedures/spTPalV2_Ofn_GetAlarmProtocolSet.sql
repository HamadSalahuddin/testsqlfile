USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPalV2_Ofn_GetAlarmProtocolSet]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPalV2_Ofn_GetAlarmProtocolSet]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPalV2_Ofn_GetAlarmProtocolSet.sql
 * Created On: 04/23/2012
 * Created By: R.Cole
 * Task #:     #3291
 * Purpose:    Return the AlarmProtocolSet data for a 
 *             single offender               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPalV2_Ofn_GetAlarmProtocolSet] (
  @OffenderID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT Offender_AlarmProtocolSetID, 
       OffenderID, 
       AlarmProtocolSetID, 
       CreatedByID
FROM Offender_AlarmProtocolSet
WHERE OffenderID = @OffenderID 
  AND Deleted = 0
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPalV2_Ofn_GetAlarmProtocolSet] TO db_dml;
GO
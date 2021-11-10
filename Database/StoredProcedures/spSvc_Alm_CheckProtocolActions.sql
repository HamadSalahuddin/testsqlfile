USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spSvc_Alm_CheckProtocolActions]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spSvc_Alm_CheckProtocolActions]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spSvc_Alm_CheckProtocolActions.sql
 * Created On: 08/16/2012
 * Created By: R.Cole 
 * Task #:     3574
 * Purpose:    Determine if there are any protocol actions
 *             for a given alarm type, and protocol set.
 *
 * Modified By: SABBASI - 19-Oct-2012
 * Detail: Added condition in the where clause Deleted = 0
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spSvc_Alm_CheckProtocolActions] (
  @AlarmProtocolEventID INT,
  @AlarmProtocolSetID INT,
--  @OffenderID INT,
  @HasActions BIT OUTPUT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SET @HasActions = CASE WHEN (SELECT TOP 1 AlarmProtocolActionID 
                             FROM AlarmProtocolAction                             
                             WHERE AlarmProtocolSetID = @AlarmProtocolSetID
                               AND AlarmProtocolEventID = @AlarmProtocolEventID
                               AND Deleted = 0) > 0 THEN 1
                       ELSE 0
                  END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spSvc_Alm_CheckProtocolActions] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Alm_GetDispositions]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Alm_GetDispositions]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Alm_GetDispositions.sql
 * Created On: 04/23/2013
 * Created By: R.Cole
 * Task #:     560
 * Purpose:    Returns a list of alarm dispositions               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Alm_GetDispositions] 
AS
   
-- // Main Query // --
SELECT AlarmDispositionID,
       AlarmDisposition
FROM AlarmDispositions
WHERE Deleted = 0
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Alm_GetDispositions] TO db_dml;
GO
USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofnd_GetReferralPrograms]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPAL_Ofnd_GetReferralPrograms]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPAL_Ofnd_GetReferralPrograms.sql
 * Created On: 04/21/2010         
 * Created By: R.Cole
 * Task #:     SA #894
 * Purpose:    Return the list of Referral Programs               
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPAL_Ofnd_GetReferralPrograms] (

) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT ReferralProgramID,
       ProgramName
FROM ReferralProgram
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPAL_Ofnd_GetReferralPrograms] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetReferralProgramByAgencyID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgramByAgencyID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetReferralProgramByAgencyID.sql
 * Created On: 02/16/2012
 * Created By: R.Cole 
 * Task #:     #2592
 * Purpose:    Get the referral programs associated with an agency               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgramByAgencyID] (
  @AgencyID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT ReferralProgramAgencyID AS ReferralProgramID,
       ProgramName
FROM ReferralProgramAgency 
WHERE AgencyID = @AgencyID
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetReferralProgramByAgencyID] TO db_dml;
GO
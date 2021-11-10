USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetReferralProgramSubTypeByAgencyID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgramSubTypeByAgencyID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetReferralProgramSubTypeByAgencyID.sql
 * Created On: 2/16/2012
 * Created By: R.Cole  
 * Task #:     #2592
 * Purpose:    Get the referral program sub types associated 
 *             with an agency
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgramSubTypeByAgencyID] (
  @AgencyID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT ReferralProgramSubType.ReferralProgramSubTypeID,
       ReferralProgramSubType.ProgramName
FROM ReferralProgramAgency 
  INNER JOIN ReferralProgramSubType ON ReferralProgramAgency.ReferralProgramAgencyID = ReferralProgramSubType.ReferralProgramAgencyID
WHERE ReferralProgramAgency.AgencyID = @AgencyID

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetReferralProgramSubTypeByAgencyID] TO db_dml;
GO
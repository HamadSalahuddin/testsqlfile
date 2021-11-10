USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetReferralProgramSubType]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgramSubType]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetReferralProgramSubType.sql
 * Created On: 02/16/2012
 * Created By: R.Cole 
 * Task #:     #2592
 * Purpose:    Retrieve Referral Program Sub Types for display
 *             in a drop down               
 *
 * Modified By: R.Cole - 02/28/2012: Revised for ReferralProgramAgencyID
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgramSubType] (
  @ReferralProgramAgencyID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT ReferralProgramSubTypeID,
       ProgramName
FROM ReferralProgramSubType
WHERE ReferralProgramAgencyID = @ReferralProgramAgencyID

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetReferralProgramSubType] TO db_dml;
GO
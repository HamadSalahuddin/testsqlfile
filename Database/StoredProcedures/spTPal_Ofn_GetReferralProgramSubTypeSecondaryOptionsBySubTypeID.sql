USE [TrackerPal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetReferralProgramSubTypeSecondaryOptionsBySubTypeID.sql
 * Created On: 04/18/2015
 * Created By: S.Khaliq
 * Task #:     #6496
 * Purpose:    Get the referral program sub types secondary options associated 
 *             with a sub type
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgramSubTypeSecondaryOptionsBySubTypeID] (
  @ID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT ReferralProgramSubTypeOptionID,Name
FROM ReferralProgramSubTypeOptions
WHERE ReferralProgramSubTypeID = @ID


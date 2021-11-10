USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetReferralProgram]') AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spTPal_Ofn_GetReferralProgram]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ******************************************************
 *   FileName:    spTPal_Ofn_GetReferralProgram.sql
 *   Created On:  15-Oct-2010
 *   Created By:  Sajid Abbasi
 *   Task #:      #894
 *   Purpose:     Get Referral Program Data
 *   
 *   Modified By:  R.Cole 11/16/2010 - Added IF EXISTS and
 *                  Grant STMTS. 
 *   Modified By:  K.Griffiths 3/5/2012 - Added ORDER BY 
 * **************************************************** */
CREATE PROCEDURE spTPal_Ofn_GetReferralProgram
AS
BEGIN
  SELECT ReferralProgramID,
         ProgramName 
  FROM ReferralProgram
  ORDER BY ProgramName ASC
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetReferralProgram] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetRefferalProgram]') AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spTPal_Ofn_GetRefferalProgram]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ******************************************************
 *   FileName:    spTPal_Ofn_GetRefferalProgram.sql
 *   Created On:  15-Oct-2010
 *   Created By:  Sajid Abbasi
 *   Task #:      #894
 *   Purpose:     Get Referral Program Data
 *   
 *   Modified By:  R.Cole 11/16/2010 - Added IF EXISTS and
 *                  Grant STMTS. 
 * **************************************************** */
CREATE PROCEDURE spTPal_Ofn_GetRefferalProgram
AS
BEGIN
	SET NOCOUNT ON;
  SELECT ReferralProgramID,
         ProgramName 
  FROM ReferralProgram
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetRefferalProgram] TO db_dml;
GO

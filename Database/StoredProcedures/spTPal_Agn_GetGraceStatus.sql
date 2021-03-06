USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTpal_Agn_GetGraceStatus]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTpal_Agn_GetGraceStatus]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Agn_GetGraceStatus.sql
 * Created On: 02/28/2015         
 * Created By: SABBASI  
 * Task #:     7638
 * Purpose:    Get status of the Grace for the agency whether enabled or not.               
 *
 * Modified By: R.Cole 3/2/2015 - Added DROP IF EXISTS and GRANT statements to the SVN'd version.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTpal_Agn_GetGraceStatus] (
	@AgencyID INT,
	@AgencyGraceStatus INT OUTPUT
)
AS
BEGIN
	SELECT @AgencyGraceStatus = ISNULL(GraceEarly, 0) + ISNULL(GraceLate, 0)
	FROM Agency 
	WHERE AgencyID = @AgencyID
END
GO

GRANT EXECUTE ON [dbo].[spTpal_Agn_GetGraceStatus] TO db_dml;
GO

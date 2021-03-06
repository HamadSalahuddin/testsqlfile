USE [Trackerpal]
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_App_GetAllStatesByCountryID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_App_GetAllStatesByCountryID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_App_GetAllStatesByCountryID.sql
 * Created On: 26-Oct-2010
 * Created By: Sajid Abbasi  
 * Task #:     #1613
 * Purpose:    Get list of states by country ID               
 *
 * Modified By: R.Cole - 11/12/2010: Added IF EXISTS and 
 *                GRANT stmts.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_App_GetAllStatesByCountryID] (
	@CountryID INT
)
AS
BEGIN
	SET NOCOUNT ON;
  SELECT StateID,
         [State],
         Abbreviation  
	FROM [State] 
	WHERE CountryID = @CountryID	
END
GO

GRANT EXECUTE ON [dbo].[spTPal_App_GetAllStatesByCountryID] TO db_dml;
GO
USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_App_GetAllStates]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_App_GetAllStates]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_App_GetAllStates.sql
 * Created On: 26-Oct-2010
 * Created By: Sajid Abbasi
 * Task #:     
 * Purpose:    Get list of states by country ID               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_App_GetAllStates]

AS
BEGIN
	SET NOCOUNT ON;
  SELECT Country.CountryID,
         s.StateID, 
         s.[State],
         s.Abbreviation
	FROM Country  
	  INNER JOIN [State] s ON Country.CountryID = s.CountryID	
END
GO

GRANT EXECUTE ON [dbo].[spTPal_App_GetAllStates] TO db_dml
GO
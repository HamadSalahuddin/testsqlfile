USE [TrackerPal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:    spTPal_vic_GetAllAgenciesByUserID.sql
 * Author:		  SOHAIL
 * Create date: 27-Feb-2016
 * Description:	This procedure gets list of all Agency which has Victim Tab enabled.
 * Task #:      8935
 * Purpose:     This stored procedure returns AgencyName and 
 *              AgencyId from Agency table based on UserID AND return only agencies that has victim tab enabled.
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_vic_GetAllAgenciesByUserID] (
  @UserID INT	
)
AS
BEGIN
	SET NOCOUNT ON;
  SELECT AgencyID, 
         Agency   
	FROM Agency 
	WHERE AgencyID IN (SELECT AgencyID 
	                   FROM Officer 
	                   WHERE UserID = @UserID)   
	      AND EnableVictimTab=1
END

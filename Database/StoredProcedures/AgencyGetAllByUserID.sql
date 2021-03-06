USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AgencyGetAllByUserID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AgencyGetAllByUserID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   [AgencyGetAllByUserID].sql
 * Created On: 19-Feb-2010         
 * Created By: Sajid Abbasi
 * Task #:     
 * Purpose:    This stored procedure returns AgencyName and 
 *             AgencyId from Agency table based on UserID               
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[AgencyGetAllByUserID] (
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
END
GO

GRANT EXECUTE ON [dbo].[AgencyGetAllByUserID] TO db_dml;
GO
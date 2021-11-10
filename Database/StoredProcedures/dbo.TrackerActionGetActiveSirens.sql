USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[TrackerActionGetActiveSirens]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.TrackerActionGetActiveSirens
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   TrackerActionGetActiveSirens.sql
 * Created On: Unknown         
 * Created By: J.Barrus  
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: R.Cole - 2/09/2010 - Redmine #715
 *              Brought up to standard
 * ******************************************************** */
CREATE PROCEDURE TrackerActionGetActiveSirens (
  @AgencyID INT = -1
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT ActiveSirens.TrackerActionID,
		              ActiveSirens.TrackerID,
		              ISNULL(Offender.LastName, '') + ', ' + ISNULL(Offender.FirstName, '') AS 'OffenderName',
                  Offender.OffenderID,
		              Tracker.AgencyID
	FROM ActiveSirens 
		INNER JOIN Tracker ON Tracker.TrackerID = s.TrackerID 
		       AND Tracker.Deleted = 0
		INNER JOIN Offender ON Offender.OffenderID = ActiveSiren.OffenderID
	WHERE @AgencyID = -1 
	   OR Tracker.AgencyID = @AgencyID
END
GO

GRANT EXECUTE ON TrackerActionGetActiveSirens TO db_dml;
GO

USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Trk_GetActiveSirens]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Trk_GetActiveSirens]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
-- =============================================
-- FileName:    spTPal_Trk_GetActiveSirens.sql
-- Author:		  Sajid Abbasi
-- Create date: 08-Sep-2010
-- Description:	This stored procedure takes the comma 
--              seperated list of offenders and returns a
--              list of those offenders which have active sirens.
-- Modified By: R.Cole - 08-Sep-2010:  Added IF EXISTS
--              and GRANT Statements.
-- =============================================
CREATE PROCEDURE spTPal_Trk_GetActiveSirens (
	@OffenderIDs VARCHAR(50)
)
AS  
BEGIN 
	SET NOCOUNT ON;

  SELECT DISTINCT	ActiveSirens.TrackerActionID,
		     ActiveSirens.TrackerID,
         Offender.OffenderID,
		     Tracker.AgencyID
	FROM ActiveSirens 
		INNER JOIN Tracker ON Tracker.TrackerID = ActiveSirens.TrackerID 
		       AND Tracker.Deleted = 0
		INNER JOIN Offender ON Offender.OffenderID = ActiveSirens.OffenderID
	WHERE	Offender.OffenderID IN (SELECT number FROM dbo.GetTableFromListId( @OffenderIDs ))
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Trk_GetActiveSirens] TO db_dml;
GO
USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Trk_GetPartNumberByTrackerID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Trk_GetPartNumberByTrackerID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Trk_GetPartNumberByTrackerID.sql
 * Created On: 27-May-2011
 * Created By: SABBASI 
 * Task #:     #2351
 * Purpose:    This SProc returns PartNumber by TrackerID               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Trk_GetPartNumberByTrackerID] (
	@TrackerID INT
)
AS
BEGIN
  SELECT DISTINCT ISNULL(Tracker.PartNumber, 0) + ' ' + ISNULL(PartNumberDetail.Description, '') AS PartNumber
	FROM Tracker 
	  INNER JOIN PartNumberDetail ON Tracker.PartNumber LIKE PartNumberDetail.PartNumber
  WHERE TrackerID = @TrackerID
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Trk_GetPartNumberByTrackerID] TO db_dml;
GO


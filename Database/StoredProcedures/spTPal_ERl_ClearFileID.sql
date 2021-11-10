USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_ERl_ClearFileID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_ERl_ClearFileID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 01-Jul-2010
-- Description:	This procedure clears all the Rules first getting rules by trackerID.
-- =============================================
CREATE PROCEDURE [dbo].[spTPal_ERl_ClearFileID]
	@TrackerID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
-- Check if temporary table already exists.
IF OBJECT_ID('tempDB..#tempT') IS NOT NULL DROP TABLE #tempT
-- Create a table to store all ERule IDs that we need to clear.
CREATE Table #tempT(ID INT)
INSERT  INTO #tempT Exec ERuleGetByTrackerID @TrackerID
-- clear file ID from rule table 
UPDATE	[Rule]
	SET		FileID = 0,
			UpdateInProgress = 0,
			UploadStatusID = 2
	WHERE	ID IN (SELECT ID FROM #tempT)
-- Clean up
DROP TABLE #tempT
END
GO

GRANT EXECUTE ON [dbo].[spTPal_ERl_ClearFileID] TO db_dml;
GO


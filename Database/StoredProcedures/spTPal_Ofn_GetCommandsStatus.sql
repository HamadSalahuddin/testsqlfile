USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetCommandsStatus]    Script Date: 05/17/2016 07:36:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetCommandsStatus.sql
 * Created On: 11/29/2014
 * Created By: SABBASI
 * Task #:     Redmine #7408      
 * Purpose:    Get status of the waiting device commands
 * 
 * Modified By: Sohail 8 Apr 2016 Task # 9998;Change select statement so that it fetch the record which was modified recently
 *              R.Cole 4/11/2016: Modified for readability and to meet standard
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetCommandsStatus] (
	@TrackerActionTypeIDs VARCHAR(500), 
  @TrackerID INT
)
AS
BEGIN	
	SELECT [number]
	INTO #tmpTrackerActionTypeIDs
	FROM GetTableFromListId(@TrackerActionTypeIDs)

	CREATE CLUSTERED INDEX #xpktmpActionType ON #tmpTrackerActionTypeIDs(number)

	SELECT Top 1 TrackerActionTypeID, 
         TrackerActionID AS 'TrackerActionID', 
         TrackerID, 
         TrackerActionDateTime 
  FROM TrackerAction 
	  INNER JOIN #tmpTrackerActionTypeIDs  ON #tmpTrackerActionTypeIDs.number =  TrackerAction.TrackerActionTypeID
  WHERE TrackerID = @TrackerID
  ORDER By TrackerActionDateTime desc

	DROP TABLE #tmpTrackerActionTypeIDs

END

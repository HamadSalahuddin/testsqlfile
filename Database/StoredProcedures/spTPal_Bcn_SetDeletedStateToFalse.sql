USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Bcn_SetDeletedStateToFalse]    Script Date: 08/11/2016 12:56:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Bcn_SetDeletedStateToFalse.sql
 * Created On: 10-Jul-2016
 * Created By: Sohail A.K
 * Task #:     #10626
 * Purpose:    This procedure set the offenderBeacon's State to false after deactivation process set it to true
 *
* ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Bcn_SetDeletedStateToFalse] (
	@ERuleIDs VARCHAR(MAX)
)	 
AS
BEGIN
 SET NOCOUNT ON;

  -- // Extract BeaconsIDs into a temp table // --
  SELECT [number]
  INTO #tmpERuleIDs
  FROM GetTableFromListId(@ERuleIDs)

  -- // Temporarily index our temp table // --
  CREATE CLUSTERED INDEX #xpktmpERuleIDs ON #tmpERuleIDs(number)

  -- // Main Query // --
 UPDATE ERule 
	SET Deleted = 0,
		DeletedDate = null,
		DeletedByID = null
	FROM ERule 
      INNER JOIN #tmpERuleIDs tmpER on ERule.ID = tmpER.number
END


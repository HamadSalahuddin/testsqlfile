USE [Trackerpal];
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetTrkEvtNoteCounts]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetTrkEvtNoteCounts]
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetTrkEvtNoteCounts.sql
 * Created On: 03/28/2011         
 * Created By: SABBASI
 * Task #:     Redmine # 1874     
 * Purpose:    Used by the Auto Refresh process to keep the note
 *             count current for events/alarms
 *
 * Modified By: R.Cole - 3/28/2011: Fixed a small copy/paste bug.
 *              R.Cole - 3/29/2011: Rewritten
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetTrkEvtNoteCounts] (	
	@OffenderIDs VARCHAR(MAX),
	@StartDateTime DATETIME,
	@EndDateTime DATETIME
)
AS
BEGIN
  
  -- // Extract OffenderIDs into a temp table // --
  SELECT [number]
  INTO #tmpOffenderIDs
  FROM GetTableFromListId(@OffenderIDs)

  -- // Index temp table for performance // --
  CREATE CLUSTERED INDEX #xpktmpOffenderIDs ON #tmpOffenderIDs(number)
 
  -- // Get final results // --
  SELECT evt.EventPrimaryID,
         evt.OffenderID,
         ((SELECT COUNT(AlarmNoteID) 
           FROM AlarmNote (NOLOCK)
           WHERE AlarmID = evt.AlarmID) + (SELECT COUNT(EventNoteID) 
                                           FROM EventNote (NOLOCK)
                                           WHERE DeviceID = evt.DeviceID 
                                             AND EventTime = evt.EventTime 
                                             AND EventID = evt.EventID)
         ) AS 'NoteCount'	
  FROM rprtEventsBucket1 (NOLOCK) evt
    INNER JOIN #tmpOffenderIDs tmpoff ON evt.OffenderID = tmpoff.[number]
  WHERE (EventDateTime BETWEEN @StartDateTime AND @EndDateTime)
    AND (((SELECT COUNT(AlarmNoteID)          -- Only return those events where note count > 0
           FROM AlarmNote (NOLOCK)
           WHERE AlarmID = evt.AlarmID) + (SELECT COUNT(EventNoteID) 
                                           FROM EventNote (NOLOCK)
                                           WHERE DeviceID = evt.DeviceID 
                                             AND EventTime = evt.EventTime 
                                             AND EventID = evt.EventID)) > 0)
  
  UNION ALL
  
  SELECT evt2.EventPrimaryID,
         evt2.OffenderID,
         ((SELECT COUNT(AlarmNoteID)
           FROM AlarmNote (NOLOCK)
           WHERE AlarmID = evt2.AlarmID) + (SELECT COUNT(EventNoteID)
                                            FROM EventNote (NOLOCK)
                                            WHERE DeviceID = evt2.DeviceID
                                              AND EventTime = evt2.EventTime
                                              AND EventID = evt2.EventID)
         ) AS 'NoteCount'
  FROM rprtEventsBucket2 (NOLOCK) evt2
    INNER JOIN  #tmpOffenderIDs tmpoff ON evt2.OffenderID = tmpoff.[number]
  WHERE (EventDateTime BETWEEN @StartDateTime AND @EndDateTime)
    AND (((SELECT COUNT(AlarmNoteID)          -- Only return those events where note count > 0
           FROM AlarmNote (NOLOCK)
           WHERE AlarmID = evt2.AlarmID) + (SELECT COUNT(EventNoteID)
                                            FROM EventNote (NOLOCK)
                                            WHERE DeviceID = evt2.DeviceID
                                              AND EventTime = evt2.EventTime
                                              AND EventID = evt2.EventID)) > 0)
END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetTrkEvtNoteCounts] TO db_dml;
GO
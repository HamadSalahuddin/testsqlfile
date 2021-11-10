USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Upd_AlarmStatusID')
  BEGIN
    DROP TRIGGER [dbo].[trg_Upd_AlarmStatusID]
    PRINT 'TRIGGER DROPPED'    
  END
ELSE
  BEGIN
    PRINT 'TRIGGER NOT PRESENT'
  END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   trg_Upd_AlarmStatusID.sql
 * Created On: 9/20/2010
 * Created By: R.Cole  
 * Task #:     #1385      
 * Purpose:    Add trigger on the AlarmAssignment table which
 *             will update the AlarmStatusID field in the 
 *             Alarm table whenever the AlarmAssignmentStatus
 *             changes.
 *
 * Modified By: R.Cole - 4/14/2011: Bug fix, added missing
 *                AFTER INSERT
 * ******************************************************** */
CREATE TRIGGER [dbo].[trg_Upd_AlarmStatusID] ON [dbo].[AlarmAssignment] AFTER INSERT, UPDATE  
AS
	IF UPDATE(AlarmAssignmentStatusID) 
	BEGIN 
		UPDATE Alarm SET AlarmStatusID = inserted.AlarmAssignmentStatusID
		FROM Alarm 
      INNER JOIN inserted	ON inserted.AlarmID = Alarm.AlarmID
	END
GO

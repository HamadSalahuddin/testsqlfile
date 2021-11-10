USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AlarmAssignmentAdd]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AlarmAssignmentAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   AlarmAssignmentAdd.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     N/A
 * Purpose:    Handle Operator Alarm Assignments
 *
 * Modified By: R.Cole - 06/19/2013: Revised per standard,
 *    added AlarmDispositionID per #560
 * Modified By:Sohail - 19 April 2014: rprtAlarmMonitorCenterGrid was update of every user that click on accept which is wrong.
						Alarm once assigned to operator should not change.added a sepatate update command for that at the end
 * ******************************************************** */
CREATE PROCEDURE [dbo].[AlarmAssignmentAdd] (
	@AlarmAssignmentID INT OUTPUT,
	@AlarmID INT,
	@AlarmAssignmentStatusID INT,
	@AssignedToID INT,
	@AssignedByID	INT,
	@AlarmDispositionID INT = NULL
)
AS

-- // Setup Variables // --
DECLARE @iOperatorAssignedTo INT,
        @bApply INT,
        @OperatorName nvarchar(50);

SET	@bApply= 1;

-- is the same operator than the assigned (RC - 6/19/2013, this original comment makes no sense)
SET @iOperatorAssignedTo = (SELECT TOP 1 AssignedToID 
						                FROM AlarmAssignment (NOLOCK)
						                WHERE AlarmID = @AlarmID	
						                ORDER BY AssignedDate DESC);

SET @OperatorName = (SELECT FirstName + ' ' + LastName FROM Operator (NOLOCK) WHERE UserID = @AssignedToID)

-- // Main Query // --
IF @iOperatorAssignedTo <> @AssignedToID 
  BEGIN
	  SET @AlarmAssignmentID=-1;
  END
ELSE 
  BEGIN
	  INSERT INTO	AlarmAssignment WITH (ROWLOCK) (
      AlarmID, 
      AlarmAssignmentStatusID, 
      AssignedToID, 
      AssignedByID,
      AlarmDispositionID
    )
	  VALUES (
      @AlarmID, 
      @AlarmAssignmentStatusID, 
      @AssignedToID, 
      @AssignedByID,
      @AlarmDispositionID
    );

	  SET @AlarmAssignmentID = SCOPE_IDENTITY();
  END

IF ((SELECT COUNT(*) FROM rprtAlarmMonitorCenterSubGrid (NOLOCK) WHERE ParentAlarmID=@Alarmid) > 0)
  BEGIN
	  --insert new records for all subalarms for this alarm
		INSERT AlarmAssignment WITH (ROWLOCK) (
      AlarmID,
      AlarmAssignmentStatusID,
      AssignedToID,
      AssignedByID
    ) 
		SELECT ALarmID,
           @AlarmAssignmentStatusID,
           @AssignedToID,
           @AssignedByID 
    From rprtAlarmMonitorCenterSubGrid 
    WHERE ParentAlarmID = @AlarmID
	END

IF @AlarmAssignmentStatusID = 4
  BEGIN
    DELETE FROM dbo.rprtAlarmMonitorCenterGrid WITH (ROWLOCK) WHERE AlarmID = @AlarmID
		DELETE FROM dbo.rprtAlarmMonitorCentersubGrid WITH (ROWLOCK) WHERE ParentAlarmid = @Alarmid
	END
ELSE 
  BEGIN
	  -- Update alarm status for the parent alarm (i.e. Stacked Alarm)
		IF ((SELECT COUNT(*) FROM rprtAlarmMonitorCenterGrid (NOLOCK) WHERE AlarmID = @AlarmID) > 0)
		  BEGIN
				UPDATE rprtAlarmMonitorCenterGrid WITH (ROWLOCK)
				  SET AlarmAssignmentStatusID = @Alarmassignmentstatusid,
				      AssignedDate = (SELECT AssignedDate FROM AlarmAssignment (NOLOCK) WHERE AlarmAssignmentID = @AlarmAssignmentID)
				  WHERE rprtAlarmMonitorCenterGrid.AlarmID = @AlarmID
				  --separate update command to update name and ID if not already updated.
				  UPDATE rprtAlarmMonitorCenterGrid WITH (ROWLOCK)
				  SET OperatorName = @OperatorName,
				      OperatorUserID = @AssignedToID 
				  WHERE rprtAlarmMonitorCenterGrid.AlarmID = @AlarmID AND OperatorUserID = 0
			END 
  END
GO

GRANT EXECUTE ON [AlarmAssignmentAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AlarmAssignmentAdd] TO [db_object_def_viewers]
GO

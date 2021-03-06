USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mMonitorCenterGridInsertAlarmRecord]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mMonitorCenterGridInsertAlarmRecord]
GO

USE [TrackerPal]
GO

/* /////////////////////////////////////////////////////////// --
-- // FileName:     mMonitorCenterGridInsertAlarmRecord     // --
-- // Created On:	Unknown                                 // --
-- // Created By:   Aculis, Inc                             // --
-- // Task #:		                                        // --
-- // Purpose:      Populate the rprtAlarmMonitorCenterGrid // --
-- //               table in the TrackerPAL db.             // -- 
-- //                                                       // --
-- // Modified By:  R.Cole - 12/16/2009 - Task #220         // --
-- /////////////////////////////////////////////////////////// */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[mMonitorCenterGridInsertAlarmRecord] (
	    @AlarmID			INT,
	    @OffenderID			INT,
	    @TrackerID			INT,
	    @EventTypeID		INT,
	    @ReceivedTime       DATETIME,
	    @AlarmTypeID		INT,
	    @Latency			INT,
	    @EventDisplayTime	DATETIME,
	    @EventName			VARCHAR(200), 
	    @OffenderName		VARCHAR(200), 
	    @GeoRuleName		VARCHAR(200),
	    @RiskLevelID		INT,
	    @SO					BIT,
	    @OPR				BIT,
	    @EventTime			BIGINT,	
	    @EventParameter     BIGINT 
)
AS

-- // Declare Var's // --
DECLARE @ParentAlarmID INT, 
        @AlarmGroupID INT

SET @ParentAlarmID = (SELECT TOP 1 AlarmID 
	                  FROM rprtAlarmMonitorCenterGrid 
	                  WHERE OffenderID = @OffenderID
		                AND TrackerID = @TrackerID
		                AND AlarmAssignmentStatusID = 1
		                AND Georule = @GeoruleName
		                AND EventTypeID = @EventTypeID
		                AND SO IS NOT NULL
		                AND OPR IS NOT NULL
		                AND DATEDIFF(HOUR, EventDisplayTime, GETDATE()) < 25)	

-- // Set the Risk Level for Demo Devices // --
IF ((SELECT IsDemo 
     FROM Tracker  
     WHERE Tracker.TrackerID = @TrackerID 
	   AND Tracker.CreatedDate = (SELECT MAX(CreatedDate) 
	                              FROM Tracker t2 
	                              WHERE t2.TrackerID = Tracker.TrackerID)) = 1)
  SET @RiskLevelID = 5

-- // Exclude CommResumes // --
IF (@EventTypeID <> 257)
  BEGIN
    IF (@ParentAlarmID IS NOT NULL) 
      -- // This is a Sub-Alarm // --
      BEGIN 
        PRINT 'this is sub-alarm'
        DECLARE @childCount INT;
	
	    -- // Get the current number of Sub-Alarms // --
	    SET @childCount = (SELECT COUNT(AlarmID) 
	                       FROM rprtAlarmMonitorCenterSubGrid 
	                       WHERE ParentAlarmID = @ParentAlarmID)
	    SET @childCount = @childCount + 2;

        -- // Insert as a Sub-Alarm // --
	    INSERT INTO rprtAlarmMonitorCenterSubGrid (
                ParentAlarmID,
		        AlarmID,
		        ReceivedTime,
		        Latency,
		        EventDisplayTime,
		        EventTime) 
	    SELECT @ParentAlarmID,  
		       Alarm.AlarmID,
		       Alarm.ReceivedTime,
		       Alarm.Latency,
		       Alarm.EventDisplayTime,
		       Alarm.EventTime
	    FROM Alarm
	    WHERE Alarm.AlarmID = @AlarmID 

        -- // Update the ChildCount on the Main MC Grid // --
        UPDATE rprtAlarmMonitorCenterGrid SET ChildCount = @childCount WHERE AlarmID = @ParentAlarmID
      END 
    ELSE
      -- // This is a normal Alarm // --
      BEGIN
        DECLARE @AgencyName nvarchar(50);
        DECLARE @EventColor nvarchar(50);
        DECLARE @TextColor nvarchar(50);
    
        -- // Get the Agency Name // --
        SET @AgencyName = (SELECT Agency.Agency
                           FROM Offender
                             INNER JOIN Agency ON Agency.AgencyID = Offender.AgencyID
                           WHERE Offender.OffenderID = @OffenderID)

        -- // Get the Alarm Display Color // --
        SELECT @EventColor = EventColor,
               @TextColor = TextColor 
        FROM AlarmType 
        WHERE AlarmTypeID = @AlarmTypeID
    
        -- // Get the GeoRule Name if applicable // --
        IF @EventTypeID IN (32,33,36,37,40,41,44,45)
	      BEGIN
            EXEC GeoruleGetNewName @Offenderid, @EventParameter, @GeoruleName OUTPUT            
	      END

	    -- // Insert as an Alarm // --
        INSERT INTO rprtAlarmMonitorCenterGrid (
	        AlarmID,
		    OffenderID,
		    TrackerID,
		    EventTypeID,
		    ReceivedTime,
		    AlarmTypeID,
		    CreatedDate,
		    Latency,
		    EventDisplayTime,
		    EventName,
		    OffenderName,
		    GeoRule,
		    RiskLevelID,
		    SO,
		    OPR,
		    EventTime,
		    AlarmAssignmentStatusID,
		    OperatorName,
		    OperatorUserID,
		    AssignedDate,
		    AgencyName,
		    EventColor,
		    TextColor,
		    EventParameter ) 
	    VALUES (
		    @AlarmID,
		    @OffenderID,
		    @TrackerID,
		    @EventTypeID,
		    @ReceivedTime,
		    @AlarmTypeID,
		    GETDATE(),
		    @Latency,
		    @EventDisplayTime,
		    @EventName,
		    @OffenderName,
		    @GeoRuleName,
		    @RiskLevelID,
		    @SO,
		    @OPR,
		    @EventTime,
		    1,
		    NULL,
		    0,
		    NULL,
		    @AgencyName,
		    @EventColor,
		    @TextColor,
		    @EventParameter )

        -- // Set the AlarmGroupID // --
        SET @AlarmGroupID = (SELECT AlarmGroupID 
	                         FROM dbo.[rprtAlarmMonitorCenterGrid]
	                         WHERE AlarmID = @AlarmID)

        UPDATE dbo.[Alarm] SET AlarmGroupID = @AlarmGroupID WHERE AlarmID = @AlarmID
      END
    --END IF
  END
--END IF
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[mMonitorCenterGridInsertAlarmRecord] TO db_dml;
GO
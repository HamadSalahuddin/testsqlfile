USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AlarmGetMonitorCenterGrid]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AlarmGetMonitorCenterGrid]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   AlarmGetMonitorCenterGrid.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     <Redmine #>      
 * Purpose:    Populate the Monitoring Center Screen               
 *
 * Modified By: R.Cole - 5/13/2010: Revised per Standard and
 *              #930 Re-Order Alarm Priority
 *              *** = High, Top of High List
 *              DEMO = High, but under ***  RiskLevelID: 5 = Demo
 *              Other High Alarms (AlarmTypeID 4), by oldest first
 *              AlarmTypeID 3, by oldest first
 *              AlarmTypeID 2, by oldest first
 *              AlarmTypeID 1, by oldest first
 *              R.Cole - #1331: Added Priority 7 to handle
 *              High Profile Offenders
 * ******************************************************** */
CREATE PROCEDURE [dbo].[AlarmGetMonitorCenterGrid] (
    @SO INT,  
    @OPR INT ,  
    @UserID INT  
)  
AS

DECLARE @RoleID INT  
SET @RoleID = (SELECT RoleID from User_Role WHERE UserID = @UserID)  
  
IF (@RoleID = 9)  -- Operations Manager  
  BEGIN  
    SELECT r.AlarmGroupID,  
           r.AlarmID,  
           r.OffenderID,  
           r.TrackerID,  
           r.EventTypeID,  
           r.EventTime,  
           r.ReceivedTime,  
           r.EventDisplayTime,  
           r.AlarmTypeID,  
           r.AlarmAssignmentStatusID,  
           r.EventParameter,  
           r.CreatedDate,  
           r.Latency,  
           r.EventName,  
           r.OffenderName,  
           r.RiskLevelID,  
           r.OperatorName,  
           r.OperatorUserID,  
           r.AssignedDate,  
           (CASE WHEN e.EventTypeGroupID = 10 THEN ISNULL(er.[Name],'N/A')
			           WHEN r.GeoRule != '' THEN ISNULL(r.GeoRule ,'N/A') 
			           ELSE 'N/A'
			     END) AS 'GeoRule',
		       r.SO,  
           r.OPR,  
           r.ChildCount,  
 	         r.AgencyName,    
           ISNULL(o.Victim, 'false') AS Victim,  
  	       r.EventColor,  
  	       r.TextColor,
  	       (CASE WHEN o.HighProfileOffender = 1 THEN 7      -- Super-Ultra-Mega-High Priority!
  	             WHEN r.OffenderName LIKE '%***%' THEN 6    -- Ultra High Priority 
  	             WHEN r.RiskLevelID = 5 THEN 5              -- DEMO Offenders
  	             ELSE AlarmTypeID
--  	            WHEN AlarmTypeID = 4 THEN 4               -- High Priority
--  	            WHEN AlarmTypeID = 3 THEN 3               -- Medium Priority
--  	            WHEN AlarmTypeID = 2 THEN 2               -- Low Priority
--  	            ELSE 1                                    -- Notifications
  	       END) AS 'Priority' 
    FROM rprtAlarmMonitorCenterGrid r  
      LEFT JOIN Offender o ON r.OffenderID = o.OffenderID  
		  LEFT JOIN Schedule s ON  s.ID =  r.EventParameter
		  LEFT JOIN ERule er ON er.ID = s.RuleID 
	    LEFT JOIN EventType e ON e.EventTypeID = r.EventTypeID
    WHERE ((@SO < 0) OR (r.SO = @SO))  
      AND ((@OPR < 0) OR (r.OPR = @OPR))  
    ORDER BY Priority DESC,
             r.EventDisplayTime
  END  
ELSE  -- MC Operator
  BEGIN
    SELECT r.AlarmGroupID,  
           r.AlarmID,  
           r.OffenderID,  
           r.TrackerID,  
           r.EventTypeID,  
           r.EventTime,  
           r.ReceivedTime,  
           r.EventDisplayTime,  
           r.AlarmTypeID,  
           r.AlarmAssignmentStatusID,  
           r.EventParameter,  
           r.CreatedDate,  
           r.Latency,  
           r.EventName,  
           r.OffenderName,  
           r.RiskLevelID,  
           r.OperatorName,  
           r.OperatorUserID,  
           r.AssignedDate,  
           (CASE WHEN e.EventTypeGroupID = 10 THEN ISNULL(er.[Name],'N/A')
                 WHEN r.GeoRule != '' THEN ISNULL(r.GeoRule ,'N/A') 
			           ELSE 'N/A'
			     END) AS 'GeoRule',
           r.SO,  
           r.OPR,  
           r.ChildCount,  
  	       r.AgencyName,    
           ISNULL(o.Victim, 'false') AS Victim,  
  	       r.EventColor,  
  	       r.TextColor,
  	       (CASE WHEN o.HighProfileOffender = 1 THEN 7      -- Super-Ultra-Mega-High Priority!
  	             WHEN r.OffenderName LIKE '%***%' THEN 6    -- Ultra High Priority 
  	             WHEN r.RiskLevelID = 5 THEN 5              -- DEMO Offenders
                 ELSE AlarmTypeID
--  	            WHEN AlarmTypeID = 4 THEN 4               -- High Priority
--  	            WHEN AlarmTypeID = 3 THEN 3               -- Medium Priority
--  	            WHEN AlarmTypeID = 2 THEN 2               -- Low Priority
--  	            ELSE 1                                    -- Notifications
  	       END) AS 'Priority'   
    FROM rprtAlarmMonitorCenterGrid r  
      LEFT JOIN Offender o ON r.OffenderID = o.OffenderID  
		  LEFT JOIN Schedule s ON  s.ID =  r.EventParameter
		  LEFT JOIN ERule er ON er.ID = s.RuleID 
	    LEFT JOIN EventType e ON e.EventTypeID = r.EventTypeID 
    WHERE ((@SO < 0) OR (r.SO = @SO))  
      AND ((@OPR < 0) OR (r.OPR = @OPR))  
      AND (OperatorUserID = @Userid OR OperatorUserID = 0)
    ORDER BY Priority DESC,
             r.EventDisplayTime
  END
GO

GRANT EXECUTE ON [dbo].[AlarmGetMonitorCenterGrid] TO db_dml;
GO
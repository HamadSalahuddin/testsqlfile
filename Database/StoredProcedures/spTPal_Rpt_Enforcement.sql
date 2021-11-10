USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_Enforcement]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_Enforcement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_Enforcement.sql
 * Created On: 04/17/2013
 * Created By: R.Cole
 * Task #:     4059
 * Purpose:    Islas battery enforcement v2               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_Enforcement] (
  @HoursBack INT = 6
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--DECLARE @HoursBack INT
--SET @HoursBack = 6

-- // Set timeframe of interest // --
DECLARE @AdjustedTime DATETIME                   
SET @AdjustedTime = DATEADD(HOUR, -@HoursBack, GETDATE())
   
-- // Main Query // --
SELECT OffenderLastName,
       OffenderFirstName
       OfficerLastName,
       [209] AS [Batt Low-TP2],
       [210] AS [Bat Critica],
       [211] AS [Bat Critica Esc],
       [212] AS [Bat Apagando]
FROM (SELECT DISTINCT Alarm.OffenderID,
             Offender.LastName AS OffenderLastName,
             Offender.FirstName AS OffenderFirstName,
             Officer.LastName AS OfficerLastName,
             Alarm.AlarmID,
             EventType.EventTypeID 
      FROM Alarm
        INNER JOIN EventType ON Alarm.EventTypeID = EventType.EventTypeID
        INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
      WHERE Alarm.EventDisplayTime > @AdjustedTime
        AND Offender.AgencyID = 35                                      -- SEGOB - Laguna del Toro
        AND EventType.EventTypeID IN (209,210,211,212)                  -- Battery events only
     ) evt
PIVOT (
  COUNT(AlarmID)
  FOR EventTypeID IN ([209],[210],[211],[212])
) AS pvt
GROUP BY OffenderLastName,                                              -- Combine to single row per offender
         OffenderFirstName,
         OfficerLastName,
         [209],
         [210],
         [211],
         [212]
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_Enforcement] TO db_dml;
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [rptInsertAlarmRecord]
	@AlarmID			int,
	@OffenderID			int,
	@TrackerID			int,
	@EventTypeID		int,
	@ReceivedTime       datetime,
	@AlarmTypeID		int,
	@Latency			int,
	@EventDisplayTime	datetime,
	@EventName			varchar(200), 
	@OffenderName		varchar(200), 
	@GeoRuleName		varchar(200),
	@RiskLevelID		int,
	@SO					bit,
	@OPR				bit,
	@EventTime			bigint

AS

DECLARE @ParentAlarmID int, @AlarmGroupID int

SET @ParentAlarmID = (
	SELECT TOP 1 AlarmID 
	FROM rprtAlarmMonitorCenterGrid 
	WHERE 
		OffenderID = @OffenderID
		AND TrackerID = @TrackerID
		AND AlarmAssignmentStatusID = 1
		AND Georule = @GeoruleName
		AND EventTypeID = @EventTypeID
		AND SO IS NOT NULL
		AND OPR IS NOT NULL
		AND DATEDIFF(hour, EventDisplayTime, GETDATE()) < 25)	

IF ((SELECT IsDemo FROM Tracker t WHERE t.TrackerID = @TrackerID 
	AND t.CreatedDate = (SELECT MAX(CreatedDate) FROM Tracker t2 WHERE t2.TrackerID = t.TrackerID)) = 1)
	SET @RiskLevelID = 5
		

IF (@ParentAlarmID IS NOT NULL) 
BEGIN 
	--insert as sub alarm
	PRINT 'this is sub-alarm'
	DECLARE @childCount int;
	SET @childCount = (SELECT COUNT(*) FROM rprtAlarmMonitorCenterSubGrid WHERE ParentAlarmID = @ParentAlarmID)
	SET @childCount = @childCount+2;

	INSERT INTO rprtAlarmMonitorCenterSubGrid (
		ParentAlarmID,
		AlarmID,
		ReceivedTime,
		Latency,
		EventDisplayTime,
		EventTime) 
	SELECT
		@ParentAlarmID,  
		a.AlarmID,
		a.ReceivedTime,
		a.Latency,
		a.EventDisplayTime,
		a.EventTime
	FROM Alarm a WITH (NOLOCK)
	WHERE a.AlarmID = @AlarmID 

	UPDATE rprtAlarmMonitorCenterGrid SET ChildCount = @childCount WHERE AlarmID = @ParentAlarmID

END 
ELSE
BEGIN
	DECLARE @AgencyName nvarchar(50);
	DECLARE @EventColor nvarchar(50);
	DECLARE @TextColor nvarchar(50);
	SET @AgencyName = (
			SELECT a.Agency
			FROM dbo.Offender o
			INNER JOIN dbo.Agency a ON a.AgencyID = o.AgencyID
			WHERE o.OffenderID = @OffenderID
	    )
	--insert as alarm
select @EventColor = EventColor,
	   @TextColor = TextColor 
from AlarmType where AlarmTypeID = @AlarmTypeID

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
		TextColor) 
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
		@TextColor)

	SET @AlarmGroupID = (SELECT AlarmGroupID FROM dbo.[rprtAlarmMonitorCenterGrid] WITH (NOLOCK)
		WHERE AlarmID = @AlarmID)

	UPDATE dbo.[Alarm]
		SET AlarmGroupID = @AlarmGroupID
		WHERE AlarmID = @AlarmID

--	SELECT  
--		a.AlarmID,
--		a.OffenderID,
--		a.TrackerID,
--		a.EventTypeID,
--		a.ReceivedTime,
--		a.AlarmTypeID,
--		a.CreatedDate,
--		a.Latency,
--		a.EventDisplayTime,
--		(
--			CASE
--			WHEN 
--				a.EventTypeID = 256 AND a.EventParameter > 0
--			THEN
--				et.AbbrevEventType + ' ' + CONVERT(nvarchar(4),a.EventParameter)
--			ELSE
--				et.AbbrevEventType
--			END
--		) AS 'EventName', 
--		ISNULL(o.FirstName + ' ', '') + ISNULL(o.LastName + ' ', '') AS 'OffenderName',
--		ISNULL(op.FirstName + ' ', '') + ISNULL(op.LastName, '') AS 'OperatorName',
--		ISNULL(op.UserID + ' ', '') AS 'OperatorUserID',
--		ISNULL(aa.AssignedDate,'') AS 'AssignedDate',
--		@georule AS 'GeoRule',
--		case WHEN t.isDemo=1 then 5 else ISNULL(o.RiskLevelID, 0) end AS 'RiskLevelID',
--		et.SO,
--		et.OPR,
--		ISNULL(aa.AlarmAssignmentStatusID,1) AS 'AlarmAssignmentStatusID',
--		a.EventTime
--	FROM Alarm a WITH (NOLOCK)
--	LEFT JOIN EventType et ON a.EventTypeID = et.EventTypeID
--	INNER JOIN Offender o ON a.OffenderID = o.OffenderID
--	LEFT JOIN AlarmAssignment aa ON a.alarmId = aa.alarmid 
--			AND aa.AssignedDate = (SELECT MAX(AssignedDate) FROM AlarmAssignment AAD WHERE aad.AlarmID = a.AlarmID)
--	LEFT JOIN AlarmAssignmentStatus aas ON aas.AlarmAssignmentStatusID = aa.AlarmAssignmentStatusID 
--	LEFT JOIN Operator op ON op.UserID = aa.AssignedToID
--	left join TRACKER t on t.TRackerID=a.TrackerID
--		AND t.CreatedDate = (SELECT MAX(CreatedDate) FROM Tracker t2 WHERE t2.TrackerID = t.TrackerID)
--	WHERE 
--		a.AlarmID=@AlarmID
END
GO
GRANT EXECUTE ON [rptInsertAlarmRecord] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [rptInsertAlarmRecord] TO [db_object_def_viewers]
GO
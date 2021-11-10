/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [MaintCreateAlarmAssignments]
	@AlarmID	int = 0
	

AS
DECLARE @maint_user_id int;
DECLARE	@EventDisplayTime datetime
SET @maint_user_id=(SELECT UserID FROM [USer] WHERE UserName='Database_Maintenance')

if (@maint_user_id IS NULL)
BEGIN 
	PRINT ' you need to create Database_Maintenance user' 
	RETURN
END
	
if (@AlarmID>0)
BEGIN
	if ((select OPR from Alarm a INNER JOIN EventTYpe et ON et.EventTYpeID=a.EventTypeID AND a.AlarmID=@AlarmID)=1)
	BEGIN
		set @EventDisplayTime=(SELECT EventDisplayTime from Alarm WHERE AlarmID=@AlarmID)
		--check if Assignemtn 2 is missing
		IF ((SELECT count(*) from TrackerPal.dbo.AlarmAssignment WHERE AlarmID=@AlarmID AND AlarmAssignmentStatusID=2)=0)
		BEGIN
			PRINT 'ALARM '+CONVERT(varchar,@AlarmID)+ ' is missing assignment 2';
			INSERT INTO TrackerPal.dbo.AlarmAssignment
				(AlarmAssignmentStatusID,AlarmID,AssignedByID,AssignedDate,AssignedToID)
				 VALUES (2,@AlarmID,@maint_user_id,DATEADD(ms,10,@EventDisplayTime),@maint_user_id)
			set @EventDisplayTime=DATEADD(ms,10,@EventDisplayTime)
			INSERT INTO TrackerPal.dbo.AlarmNote (AlarmID, Note, CreatedByID)
				 VALUES    (@AlarmID, 'Operator Alarm Assignment 2 was generated by the system', @maint_user_id)
		END
		--check if Assignemtn 3 is missing
		IF ((SELECT count(*) from TrackerPal.dbo.AlarmAssignment WHERE AlarmID=@AlarmID AND AlarmAssignmentStatusID=3)=0)
		BEGIN
			IF ((SELECT  count(*) FROM    TrackerPal.dbo.AlarmProtocolAction apa INNER JOIN TrackerPal.dbo.Offender_AlarmProtocolSet oaps ON
				apa.AlarmProtocolSetID = oaps.AlarmProtocolSetID AND oaps.Deleted = 0 INNER JOIN TrackerPal.dbo.AlarmProtocolEvent ape ON
				apa.AlarmProtocolEventID = ape.AlarmProtocolEventID INNER JOIN TrackerPal.dbo.Alarm a ON ape.GatewayEventID = a.EventTypeID AND
				a.offenderid = oaps.offenderid WHERE a.AlarmID = @AlarmID AND apa.Deleted = 0)>0)
			BEGIN
				--there are protocols for this alarm
				PRINT 'ALARM '+CONVERT(varchar,@AlarmID)+ ' has protocols but no assignment 3';
				INSERT INTO TrackerPal.dbo.AlarmAssignment
					(AlarmAssignmentStatusID,AlarmID,AssignedByID,AssignedDate,AssignedToID)
					VALUES (3,@AlarmID,@maint_user_id,DATEADD(ms,10,@EventDisplayTime),@maint_user_id)
				set @EventDisplayTime=DATEADD(ms,10,@EventDisplayTime)
				INSERT INTO TrackerPal.dbo.AlarmNote (AlarmID, Note, CreatedByID)
					VALUES    (@AlarmID, 'Operator Alarm Assignment 3 was generated by the system', @maint_user_id)
			END
		END
		--check if Assignemtn 4 is missing
		IF ((SELECT count(*) from TrackerPal.dbo.AlarmAssignment WHERE AlarmID=@AlarmID AND AlarmAssignmentStatusID=4)=0)
		BEGIN
			PRINT 'ALARM '+CONVERT(varchar,@AlarmID)+ ' has no assignment 4';
			INSERT INTO TrackerPal.dbo.AlarmAssignment
				(AlarmAssignmentStatusID,AlarmID,AssignedByID,AssignedDate,AssignedToID)
				VALUES (4,@AlarmID,@maint_user_id,DATEADD(ms,10,@EventDisplayTime),@maint_user_id)
			INSERT INTO TrackerPal.dbo.AlarmNote (AlarmID, Note, CreatedByID)
				VALUES    (@AlarmID, 'Operator Alarm Assignment 4 was generated by the system', @maint_user_id)
		END
	END
	ELSE
	BEGIN
		PRINT 'this alrm will not seen by operator';
	END
END 



GO
GRANT VIEW DEFINITION ON [MaintCreateAlarmAssignments] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [MaintCreateAlarmAssignments] TO [db_dml]
GO

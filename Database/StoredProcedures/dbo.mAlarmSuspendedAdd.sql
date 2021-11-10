/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAlarmSuspendedAdd]
 @AlarmSuspendedID bigint output,  
 @AgencyID bigint,  
 @OfficerID  bigint,  
 @OffenderID  bigint,  
 @RequestingOfficerID  bigint,  
 @AlarmProtocolEventID  bigint,  
 @StartTime  DateTime,  
 @EndTime  DateTime,  
 @CreatedBy  bigint,  
 @CreatedDate DateTime OUTPUT,  
 @ConfirmationNumber bigint,
 @ZoneIDs nvarchar(250)  
AS  
  
SET @CreatedDate = GETDATE()  
  
INSERT INTO AlarmSuspended  
 (AgencyID,OfficerID,OffenderID,RequestingOfficerID,AlarmProtocolEventID,StartTime,EndTime,CreatedDate,CreatedBy,ConfirmationNumber,ZoneIDs)  
VALUES  
 (@AgencyID,@OfficerID,@OffenderID,@RequestingOfficerID,@AlarmProtocolEventID,@StartTime,@EndTime,@CreatedDate,@CreatedBy,@ConfirmationNumber,@ZoneIDs)  
  
SET @AlarmSuspendedID = SCOPE_IDENTITY()
GO
GRANT EXECUTE ON [mAlarmSuspendedAdd] TO [db_dml]
GO
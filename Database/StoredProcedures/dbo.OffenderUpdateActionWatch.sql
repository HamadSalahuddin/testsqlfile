/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderUpdateActionWatch]
	@iAgencyID int,	
	@iOffenderID int,
	@iUserID int,
	@iDeviceID int
AS

UPDATE OffenderActionWatch
   SET AlarmOffTime = GetDate(),
      Enabled = 0
WHERE AgencyID = @iAgencyID
and OffenderID = @iOffenderID
and UserID = @iUserID
and DeviceID = @iDeviceID
and Enabled = 1



GO
GRANT VIEW DEFINITION ON [OffenderUpdateActionWatch] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderUpdateActionWatch] TO [db_dml]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderCreateActionWatch]
	@iOffenderActionWatchID int OUTPUT,
	@iAgencyID int,	
	@iOffenderID int,
	@iDeviceID int,
	@iUserID int

AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO OffenderActionWatch
           (AgencyID, OffenderID, DeviceId, UserId, AlarmOnTime, CreatedDate, CreatedBy, Enabled)
     VALUES(@iAgencyID, @iOffenderID, @iDeviceID, @iUserID, GetDate(), GetDate(), @iUserID, 1)


	SET @iOffenderActionWatchID = @@IDENTITY
END





GO
GRANT VIEW DEFINITION ON [OffenderCreateActionWatch] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderCreateActionWatch] TO [db_dml]
GO
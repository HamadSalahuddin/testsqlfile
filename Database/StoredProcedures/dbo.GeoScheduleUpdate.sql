/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoScheduleUpdate]

        @GeoScheduleId                                  uniqueidentifier,
        @Name                           nchar(50),
        @Description            nchar(50),
        @ScheduleState          int,
        @ScheduleStateTime      DateTime,
        @AssignedOffender   INT,
		@OwnerID int

AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRAN
        UPDATE  GeoSchedule
                SET
                [Name] = @Name,
                Description =@Description,
                ScheduleState = @ScheduleState  ,
                ScheduleStateTime = @ScheduleStateTime,
                AssignedOffender=@AssignedOffender,
				OwnerID= @OwnerID
        WHERE Id = @GeoScheduleId
	COMMIT TRAN
END



GO
GRANT EXECUTE ON [GeoScheduleUpdate] TO [db_dml]
GO

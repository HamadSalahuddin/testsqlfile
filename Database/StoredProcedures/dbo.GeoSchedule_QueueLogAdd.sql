/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoSchedule_QueueLogAdd]
	
	@QueueLogID                 INT OUTPUT,
	@QueueSegmentID 			INT,
	@AttemptTime				DATETIME,
	@GatewayRequestID			INT,
	@UploadStatus				INT



AS



INSERT INTO GeoScheduleQueueLog
(QueueSegmentID , AttemptTime,GatewayRequestID,UploadStatus)
VALUES
(@QueueSegmentID ,@AttemptTime,@GatewayRequestID,@UploadStatus)


SET @QueueLogID = @@IDENTITY
GO
GRANT EXECUTE ON [GeoSchedule_QueueLogAdd] TO [db_dml]
GO

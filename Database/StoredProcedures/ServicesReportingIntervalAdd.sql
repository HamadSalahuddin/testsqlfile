/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ServicesReportingIntervalAdd]
	@AgencyID int,
    @ServiceID int,
    @IntervalID int,
    @AvailabilityID int,
    @Cost float
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO servicesReportingInterval 
	(AgencyID,ServiceID,IntervalID,AvailabilityID,Cost)
	VALUES
	(@AgencyID,@ServiceID,@IntervalID,@AvailabilityID,@Cost)
END

GO
GRANT EXECUTE ON [ServicesReportingIntervalAdd] TO [db_dml]
GO

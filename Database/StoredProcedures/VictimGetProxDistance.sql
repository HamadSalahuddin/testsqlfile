/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [VictimGetProxDistance]
        @VictimID       INT,
        @ProxAlertDistance      INT OUTPUT,
        @ProxViolationDistance  INT OUTPUT

AS

        SELECT  @ProxAlertDistance = ISNULL(VictimProxAlertDistance, 0),
                @ProxViolationDistance = ISNULL(VictimProxViolationDistance, 0)
        FROM    dbo.Offender o
        WHERE   OffenderID = @VictimID


GO
GRANT EXECUTE ON [VictimGetProxDistance] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [VictimGetProxDistance] TO [db_object_def_viewers]
GO
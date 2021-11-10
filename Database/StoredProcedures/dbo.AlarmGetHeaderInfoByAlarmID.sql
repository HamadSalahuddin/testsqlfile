/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmGetHeaderInfoByAlarmID]
        @iAlarmID int

AS
BEGIN
        SET NOCOUNT ON;

        SELECT e.AbbrevEventType as EventType, a.EventDisplayTime ,
        isnull(g.AlarmInstructions,'')as AlarmInstructions,
        isnull(g.GeoRuleName,'') as GeoRuleName,
        tz.utcoffset,
                trackerpal.dbo.fnUtcToLocal(o.agencyid, a.EventDisplayTime) as AgencyEventDisplayTime
        FROM Alarm a
        left join offender o on a.offenderid = o.offenderid
        left join agency ag on ag.agencyID = o.agencyID
        left join timezone tz on ag.timezoneid = tz.timezoneid
        left join EventType e on e.EventTypeId=a.EventTypeId
        left join Georule g on g.georuleid= a.EventParameter and a.eventTypeID IN (44,45,35,36)
        WHERE   a.AlarmID = @iAlarmID


END




GO
GRANT EXECUTE ON [AlarmGetHeaderInfoByAlarmID] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AlarmGetHeaderInfoByAlarmID] TO [db_object_def_viewers]
GO
/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetLastStatusUpdateTime]

	@OffenderID	INT,
	@SO			INT,
	@OPR		INT

AS


		SELECT	top 1 e.EventTime as 'StatusUpdateTime'
		
		FROM  Gateway.dbo.Events e 
 		JOIN EventType et ON e.EventID = et.EventTypeID 
		join OffenderTrackerActivation ota on ota.OffenderID = @OffenderID and ota.TrackerID =e.deviceID AND(
			 (ota.activateDate< Convert(DateTime,
			(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
			DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	and ota.DeActivateDate> Convert(DateTime,
			(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
			DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0)))))
	or
	(ota.activateDate<Convert(DateTime,
			(DATEADD(ms, (e.EventTime / CAST(10000 AS bigint)) % 86400000,
			DATEADD(day, e.EventTime / CAST(864000000000 AS bigint) - 109207, 0))))
	 and ota.DeActivateDate is null))
	WHERE	e.Eventid=0
				and (
					(@SO<0)
					or
					 (et.SO=@SO)
				)
				and (
					(@OPR<0)
					or
					(et.OPR=@OPR)
				)
				
	ORDER BY e.eventtime desc







/*
LEFT JOIN Gateway.dbo.Events e2 on e2.DeviceID = o.TrackerID and e2.Eventid=0 and e2.EventTime = (select MAX(EventTime) from Gateway.dbo.Events e1 where e1.DeviceID = o.TrackerID and e1.Eventid=0)
		
*/
GO
GRANT VIEW DEFINITION ON [OffenderGetLastStatusUpdateTime] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderGetLastStatusUpdateTime] TO [db_dml]
GO

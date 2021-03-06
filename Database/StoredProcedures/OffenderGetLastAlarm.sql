USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[OffenderGetLastAlarm]    Script Date: 05/11/2018 06:24:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER Procedure [dbo].[OffenderGetLastAlarm]

	@OffenderID	INT,
	@SO			INT,
	@OPR		INT

AS


		SELECT	top 1 
				a.EventTypeID AS 'StatusID',
				et.AbbrevEventType  AS 'EventType',
				a.AlarmID,
				a.EventTime AS 'LastEventTime',
                a.EventDisplayTime AS 'LastEventDisplayTime'		
		
		FROM  Alarm a 
 		JOIN EventType et ON a.EventTypeID = et.EventTypeID 
		join OffenderTrackerActivation ota on ota.OffenderID = a.OffenderID and ota.TrackerID =a.TrackerID AND(
			 (ota.activateDate< a.EventDisplayTime
			 and ota.DeActivateDate> a.EventDisplayTime)
			or
			(ota.activateDate<a.EventDisplayTime
			 and ota.DeActivateDate is null))
	WHERE	a.OffenderID = @OffenderID 	
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
				
	ORDER BY a.eventtime desc

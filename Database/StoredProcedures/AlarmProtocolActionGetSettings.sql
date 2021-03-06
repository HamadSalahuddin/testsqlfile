USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[AlarmProtocolActionGetSettings]    Script Date: 11/09/2013 15:07:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   AlarmProtocolActionGetSettings.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc
 * Task #:     N/A      
 * Purpose:    Retrieves alarm information used by in 
 *             TrackerPAL alarm notifications
 *
 * Modified By: R.Cole - 02/22/2010   Added GeoRuleName Field
 *              S.Abbasi - 02/23/2010 Bug Fix to GeoRuleName
 *              S.Abbasi - 03/01/2010 SA_318 Added EventDateTime
 *				S.Abbasi - 04/06/2012 Bug #3241; Added officerName, 
 *				Latitude, Longitude,HomePhone1 and Address fields in the resultset.
 *              R.Cole - 4/10/2012: Added code to concatenate
 *        all phone numbers into one field in the resultset. 
 *              SABBASI - 04/20/2012; Task #3294; We need 
 *       AlarmTypeID in the result set to decide type of alarm.
 *              R.Cole - 5/22/2012: Per #3379, changed
 *                LongName to AbbrevEventType
 *  SABBASI - 15-Nov-2012 Added AlarmFullName field under Bug #3465 
 * ******************************************************** */
ALTER PROCEDURE [dbo].[AlarmProtocolActionGetSettings] (
  @AlarmProtocolActionID INT,  
  @AlarmID INT,  
  @OffenderID INT  
)  
AS

DECLARE @EventTypeID INT,
        @EventParameter BIGINT,
		    @GeoRuleName VARCHAR(50),
    		@EventDateTime DATETIME  

-- // Get the EventType, EventParam, and EventTime // --
SELECT @EventTypeID = ISNULL(EventTypeID, 0), 
       @EventDateTime = dbo.ConvertLongToDate(EventTime),
	     @EventParameter = ISNULL(EventParameter, 0)	  
FROM	Alarm
WHERE	AlarmID = @AlarmID

-- // Get the GeoRule Name // -- 
IF @EventTypeID IN (32,33,36,37,40,41,44,45)
  BEGIN                        
    SELECT @GeoRuleName = GeoRule.GeoRuleName
    FROM GeoRule_Offender
      INNER JOIN GeoRule ON GeoRule.GeoRuleID = GeoRule_Offender.GeoRuleID
    WHERE GeoRule_Offender.OffenderID = @OffenderID 
      AND GeoRule_Offender.ZoneID = @EventParameter
  END
ELSE
  SET @GeoRuleName = ''
  
-- // Main Query // --  
SELECT EventType.AbbrevEventType AS 'AlarmName',  
       EventType.LongName AS 'AlarmFullName',  
       Offender.FirstName + ' ' + Offender.LastName AS 'OffenderName',  
       (CASE WHEN DateAdd(mi, tz.UTCOFFSET, Alarm.ReceivedTime) BETWEEN ds.start AND ds.[end]
             THEN DateAdd(mi, tz.DaylightUTCOFFSET, Alarm.ReceivedTime)
             ELSE DateAdd(mi, tz.UTCOFFSET, Alarm.ReceivedTime)END
       )AS 'ReceivedTime',
       (CASE WHEN DateAdd(mi, tz.UTCOFFSET, @EventDateTime) BETWEEN ds.start AND ds.[end]
             THEN DateAdd(mi, tz.DaylightUTCOFFSET, @EventDateTime)
             ELSE DateAdd(mi, tz.UTCOFFSET, @EventDateTime)END
       )AS 'EventDateTime',
       evt.ExternalBatteryVoltage,   
       apas.MessageSubject,  
       apas.MessageBody, 
       @GeoRuleName AS 'GeoRuleName',
	     Officer.FirstName + ' ' + Officer.LastName AS 'Officer',
	     Alarm.Latitude,
	     Alarm.Longitude,
	     Alarm.Address,
		   ISNULL(Alarm.EventTypeID, 0) AS 'EventTypeID',
       CASE ISNULL((CASE Offender.HomePhone1 WHEN '' THEN NULL ELSE pt1.PhoneType + ': ' + Offender.HomePhone1 + ' ' END), '') + 
            ISNULL((CASE Offender.HomePhone2 WHEN '' THEN NULL ELSE pt2.PhoneType + ': ' + Offender.HomePhone2 + ' ' END), '') +
            ISNULL((CASE Offender.HomePhone3 WHEN '' THEN NULL ELSE pt3.PhoneType + ': ' + Offender.HomePhone3 + ' ' END), '') 
            WHEN '' THEN 'N/A'
            ELSE ISNULL((CASE Offender.HomePhone1 WHEN '' THEN NULL ELSE pt1.PhoneType + ': ' + Offender.HomePhone1 + ' ' END), '') + 
                 ISNULL((CASE Offender.HomePhone2 WHEN '' THEN NULL ELSE pt2.PhoneType + ': ' + Offender.HomePhone2 + ' ' END), '') +
                 ISNULL((CASE Offender.HomePhone3 WHEN '' THEN NULL ELSE pt3.PhoneType + ': ' + Offender.HomePhone3 + ' ' END), '') 
       END AS PhoneContact
FROM AlarmProtocolAction apa  
  INNER JOIN AlarmProtocolEvent ape ON apa.AlarmProtocolEventID = ape.AlarmProtocolEventID  
  INNER JOIN EventType ON ape.GatewayEventID = EventType.EventTypeID  
  INNER JOIN AlarmProtocolActionSettings apas ON apa.AlarmProtocolEventID = apas.AlarmProtocolEventID  
  INNER JOIN Alarm ON ape.GatewayEventID = Alarm.EventTypeID  
  INNER JOIN Gateway.dbo.Events evt ON Alarm.TrackerID = evt.DeviceID 
         AND Alarm.EventTypeID = evt.EventID 
         AND Alarm.EventTime = evt.EventTime  
  INNER JOIN Offender ON Alarm.OffenderID = Offender.OffenderID 
  INNER JOIN Offender_Officer oo ON oo.OffenderID = Offender.OffenderID
  INNER JOIN Officer ON Officer.OfficerID = oo.OfficerID
  INNER JOIN Agency ON Agency.AgencyID = Offender.AgencyID
  INNER JOIN Timezone tz ON tz.TimezoneID = Agency.TimezoneID
	INNER JOIN DaylightSaving ds ON ds.[year] = DATEPART(yy, Alarm.ReceivedTime)
  LEFT OUTER JOIN PhoneType pt1 ON Offender.HomePhone1TypeID = pt1.PhoneTypeID 
  LEFT OUTER JOIN PhoneType pt2 ON Offender.HomePhone2TypeID = pt2.PhoneTypeID
  LEFT OUTER JOIN PhoneType pt3 ON Offender.HomePhone3TypeID = pt3.PhoneTypeID
WHERE apa.AlarmProtocolActionID = @AlarmProtocolActionID 
  AND Alarm.AlarmID = @AlarmID 
  AND Alarm.OffenderID = @OffenderID 
  AND apa.Deleted = 0

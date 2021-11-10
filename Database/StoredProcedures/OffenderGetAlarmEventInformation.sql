USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OffenderGetAlarmEventInformation]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OffenderGetAlarmEventInformation]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   OffenderGetAlarmEventInformation.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     
 * Purpose:                   
 *
 * Modified By: Sajid 6/2/2011: Added PartNumber for #2351
 *              R.Cole 6/2/2011: Cleaned up the legacy code.
 * ******************************************************** */
CREATE PROCEDURE [OffenderGetAlarmEventInformation] (
  @OffenderID INT,  
  @AlarmID INT  
)  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 SELECT TOP 1 ISNULL(Offender.FirstName, '') + ' ' + ISNULL(Offender.MiddleName, '') + ' ' + ISNULL(Offender.LastName, '') AS 'OffenderName',
        ISNULL(Offender.CaseNumber, '') AS CaseNumber,
        ISNULL(Tracker.TrackerNumber, '') AS TrackerNumber,  
        ISNULL(Officer.FirstName, '') + ' ' + ISNULL(Officer.MiddleName, '') + ' ' + ISNULL(Officer.LastName, '') AS 'OfficerName',  
        Officer.DayPhone,  
        Officer.EveningPhone,  
        Officer.MobilePhone,  
        Officer.EmailAddress1,  
        Officer.EmailAddress2,  
        ISNULL(gwDevices.[Name], '') AS 'DeviceFriendlyName',  
        ISNULL(PrimaryLanguage.[PrimaryLanguage], '') AS 'PrimaryLanguage',  
        ISNULL(Officer.ExtDayPhone, '') AS 'ExtDayPhone',  
        ISNULL(Officer.ExtEveningPhone, '') AS 'ExtEveningPhone',  
        Tracker.TrackerID,
        ISNULL(Tracker.PartNumber, 0) + ' ' + ISNULL(PartNumberDetail.Description, '') AS PartNumber,   
        Agency.Agency,
        Alarm.address  
 FROM Offender
  LEFT JOIN Alarm ON Alarm.OffenderID = @OffenderID 
        AND Alarm.AlarmID = @AlarmID  
  LEFT JOIN Tracker ON Tracker.TrackerID = Alarm.TrackerID 
  LEFT JOIN PartNumberDetail ON Tracker.PartNumber LIKE PartNumberDetail.PartNumber       
  LEFT JOIN Offender_Officer ON Offender_Officer.OffenderID = @OffenderID  
  LEFT JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID    
  LEFT JOIN Gateway.dbo.Devices gwDevices ON gwDevices.DeviceID = Tracker.TrackerID 
  LEFT JOIN Agency ON Offender.AgencyID = Agency.AgencyID 
  LEFT JOIN PrimaryLanguage ON PrimaryLanguage.PrimaryLanguageID = Offender.PrimaryLanguageID    
 WHERE Offender.OffenderID = @OffenderID  
END
GO

GRANT EXECUTE ON [OffenderGetAlarmEventInformation] TO [db_dml]
GO
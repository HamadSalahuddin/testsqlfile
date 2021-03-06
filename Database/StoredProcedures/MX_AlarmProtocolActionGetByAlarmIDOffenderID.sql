USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AlarmProtocolActionGetByAlarmIDOffenderID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AlarmProtocolActionGetByAlarmIDOffenderID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   AlarmProtocolActionGetByAlarmIDOffenderID.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc.
 * Task #:     <Redmine #>      
 * Purpose:                   
 *
 * Modified By: R.Cole - 07/27/2011: Brought up to std and
 *                readability edits.  Localized the string
 *                compares for Mexico deployment.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[AlarmProtocolActionGetByAlarmIDOffenderID] (
    @AlarmID INT,    
    @OffenderID INT,
    @AgencyTime VARCHAR(20) = NULL   
)
AS   

SELECT DISTINCT apa.AlarmProtocolActionID, 
       apa.AlarmProtocolSetID, 
       apa.AlarmProtocolEventID,    
       apa.[Type], 
       apa.Priority, 
       apa.[From], 
       apa.[To], 
       apa.[Action],    
       -- Recipient
       CASE apa.Recipient WHEN 'Copia de seguridad contacto' THEN trackerpal.dbo.fnGetBackupContatRecipient(apa.ContactInfo,o.OfficerID)      
                          WHEN 'Oficial asignado' THEN 'Oficial: ' + o.FirstName + ' ' + o.LastName    
                          WHEN 'Agencia' THEN 'Agencia: ' + ag.Agency      
                          WHEN 'Delincuente' THEN CASE offend.Victim WHEN 1 THEN 'Delincuente: ' + offend2.Firstname + ' ' + offend2.LastName     
                                                                  ELSE 'Delincuente: ' + offend.FirstName + ' ' + offend.LastName    
                                               END    
                          WHEN 'Victima' THEN 'Victima: ' + offend.FirstName + ' ' + offend.LastName 
                          WHEN 'Backup Contact' THEN trackerpal.dbo.fnGetBackupContatRecipient(apa.ContactInfo,o.OfficerID)
                          WHEN 'Assigned Officer' THEN 'Officer: ' + o.FirstName + ' ' + o.LastName
                          WHEN 'Agency' THEN 'Agency: ' + ag.Agency
                          WHEN 'Offender' THEN CASE offend.Victim WHEN 1 THEN 'Offender: ' + offend2.Firstname + ' ' + offend2.LastName
                                                                  ELSE 'Offender: ' + offend.FirstName + ' ' + offend.LastName
                                               END
                          WHEN 'Victim' THEN 'Victim: ' + offend.FirstName + ' ' + offend.LastName
                          WHEN 'NA' THEN apa.Recipient
                          ELSE trackerpal.dbo.fnGetOtherrecipient(apa.Recipient)   
       END AS 'Recipient', --'Recipiente',    
       -- ContactInfo
       CASE apa.ContactInfo WHEN 'Teléfono del trabajo de la víctima (Oficina)' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,4)    
              WHEN 'Número de teléfono móvil de la víctima' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,4)    
              WHEN 'Víctima Teléfono de la casa #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,4)    
              WHEN 'Contacto de víctima alternativo de trabajo #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,4)    
              WHEN 'Contacto de víctima alternativo móvil #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,4)    
              WHEN 'Víctima Contacto Alternativo De la casa #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,4)    
              WHEN 'Número de teléfono de trabajo oficial (Oficina)' THEN o.DayPhone    
              WHEN 'Número de teléfono móvil oficial' THEN o.MobilePhone    
              WHEN 'Número de teléfono de la casa oficial' THEN o.EveningPhone    
              WHEN 'En llamada número de teléfono' THEN ag.OnCallPhone
 	            WHEN 'Agencia primaria número' THEN ag.Phone       
              WHEN 'Localizador Oficial #' THEN o.Pager    
              WHEN 'En la llamada Localizador #' THEN ag.OnCallPager    
              WHEN 'Correo Electrónico Oficial' THEN o.EmailAddress1    
              WHEN 'Otro funcionario de Correo Electrónico' THEN o.EmailAddress2    
              WHEN 'Correo electrónico de la Agencia' THEN ag.EmailAddress    
              WHEN 'El correo electrónico de la llamada' THEN ag.OnCallEmail    
              WHEN 'Número de dispositivo de delincuente' THEN NULL    
              WHEN 'Dispositivo de víctima' THEN NULL    
              WHEN 'Copia de seguridad Contacto1 teléfono #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(1,0,o.OfficerID),'')        
              WHEN 'Copia de seguridad Contacto2 teléfono #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(2,0,o.OfficerID) ,'')           
              WHEN 'Copia de seguridad Contacto3 teléfono #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(3,0,o.OfficerID) ,'')           
              WHEN 'Copia de seguridad Contacto4 teléfono #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(4,0,o.OfficerID)  ,'')          
              WHEN 'Copia de seguridad de correo electrónico contact1' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(1,1,o.OfficerID)  ,'')          
              WHEN 'Copia de seguridad de correo electrónico contact2' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(2,1,o.OfficerID) ,'')           
              WHEN 'Copia de seguridad de correo electrónico contact3' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(3,1,o.OfficerID) ,'')           
              WHEN 'Copia de seguridad de correo electrónico contact4' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(4,1,o.OfficerID)  ,'')          
              WHEN 'Victim Work (Office) Phone #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,4)
              WHEN 'Victim Mobile Phone #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,4)
              WHEN 'Victim Home Phone #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,4)    
              WHEN 'Victim Alternate Contact Work #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,4)
              WHEN 'Victim Alternate Contact Mobile #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,4)    
              WHEN 'Victim Alternate Contact Home #' THEN trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,4)    
              WHEN 'Officer Work (Office) Phone #' THEN o.DayPhone    
              WHEN 'Officer Mobile Phone #' THEN o.MobilePhone    
              WHEN 'Officer Home Phone #' THEN o.EveningPhone    
              WHEN 'On Call Phone #' THEN ag.OnCallPhone
              WHEN 'Primary Agency Number' THEN ag.Phone       
              WHEN 'Officer Pager #' THEN o.Pager    
              WHEN 'On Call Pager #' THEN ag.OnCallPager    
              WHEN 'Officer Email' THEN o.EmailAddress1    
              WHEN 'Officer Other Email' THEN o.EmailAddress2    
              WHEN 'Agency Email' THEN ag.EmailAddress    
              WHEN 'On Call Email' THEN ag.OnCallEmail    
              WHEN 'Offender Device' THEN NULL    
              WHEN 'Victim Device' THEN NULL    
              WHEN 'Backup Contact1 Phone #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(1,0,o.OfficerID),'')        
              WHEN 'Backup Contact2 Phone #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(2,0,o.OfficerID) ,'')           
              WHEN 'Backup Contact3 Phone #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(3,0,o.OfficerID) ,'')           
              WHEN 'Backup Contact4 Phone #' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(4,0,o.OfficerID)  ,'')          
              WHEN 'Backup Contact1 Email' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(1,1,o.OfficerID)  ,'')          
              WHEN 'Backup Contact2 Email' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(2,1,o.OfficerID) ,'')           
              WHEN 'Backup Contact3 Email' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(3,1,o.OfficerID) ,'')           
              WHEN 'Backup Contact4 Email' THEN ISNULL(trackerpal.dbo.fnGetBackupContatInfo(4,1,o.OfficerID)  ,'')
              WHEN 'N/A' THEN apa.ContactInfo   
              WHEN 'NA' THEN apa.ContactInfo   
              ELSE  trackerpal.dbo.fnGetOtherContacInfo('' + apa.Recipient + '/' + apa.ContactInfo + '')  
       END AS 'ContactInfo', --'Info de contacto',
       apa.Retry, 
       apa.Note,
       CASE ISNULL(CONVERT(VARCHAR,oapa.CompletedDate),'0') WHEN '0' THEN 0 ELSE 1 END AS completed,
       a.TrackerID    
FROM AlarmProtocolAction apa    
  INNER JOIN Offender_AlarmProtocolSet oaps ON apa.AlarmProtocolSetID = oaps.AlarmProtocolSetID 
         AND oaps.Deleted = 0    
  INNER JOIN AlarmProtocolEvent ape ON apa.AlarmProtocolEventID = ape.AlarmProtocolEventID 
  INNER JOIN Alarm a ON ape.GatewayEventID = a.EventTypeID
  INNER JOIN Offender offend ON a.OffenderID = offend.OffenderID    
  LEFT OUTER JOIN Offender offend2 ON offend.VictimAssociatedOffenderID = offend2.offenderid    
  INNER JOIN Offender_Officer oo ON offend.OffenderID = oo.OffenderID    
  LEFT OUTER JOIN dbo.OffenderTrackerActivation ota ON ota.offenderid= offend.VictimAssociatedOffenderID     
              AND ActivateDate = (SELECT MAX(ActivateDate)     
                                  FROM dbo.OffenderTrackerActivation WHERE offenderid=offend.VictimAssociatedOffenderID)
  INNER JOIN Officer o ON oo.OfficerID = o.OfficerID    
  INNER JOIN Agency ag ON o.AgencyID = ag.AgencyID    
  LEFT OUTER JOIN dbo.Operator_AlarmProtocolAction oapa ON a.alarmid = oapa.alarmid 
              AND apa.AlarmProtocolActionID = oapa.AlarmProtocolActionID       
WHERE oaps.OffenderID = @OffenderID 
  AND a.AlarmID = @AlarmID 
  AND apa.Deleted = 0    
ORDER BY apa.Priority
GO

GRANT EXECUTE ON [dbo].[AlarmProtocolActionGetByAlarmIDOffenderID] TO db_dml;
GO

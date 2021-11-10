USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[AlarmProtocolActionGetByAlarmIDOffenderID]    Script Date: 05/10/2016 10:00:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   [AlarmProtocolActionGetByAlarmIDOffenderID].sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     N/A
 * Purpose:    Return Alarm Protocol actions to the MC Screen               
 *
 * Modified By: SABBASI - 3/30/2012: Added Officer and Agency
 *              SMS to the Contact Info section (#3114)
 *              R.Cole - 4/17/2012: Revised formatting of 
 *              orginal code for readability and to meet standard.
 *              SKHALIQ - 17 JAN 2014: # 3165 - Included Backup Contact Text Message information
 *				R.Cole - 2/14/2014: Added missing localization
 *				SABBASI - 02/17/2014: Added option WHEN 'N/A' then apa.Recipient for CASE apa.Recipient
 *				SABBASI - 02/17/2014: Added option WHEN 'Dispositivo de víctima' , Added Víctima in recipient case
 *				SABBASI - 02/19/2014: Added option WHEN 'Número de teléfono móvil (Oficial)'  THEN o.MobilePhone
 *				Added option WHEN 'Número de teléfono de la casa (Oficial)' THEN o.EveningPhone 
 *				Added option WHEN 'Otro E-mail del Oficial' THEN o.EmailAddress2
 *				SOHAIL - 22 Feb 2014:Added case for Recipient "Condenado" as per Task # 5609
 *              SOHAIL - 22 Feb 2014:Added case for Recipient "Contacto de Respaldo" as per Task # 5609 comment # 3
 *              H.SALAHUDDIN -25 Feb 2014: Modified to reflect IDs instead of string comparison as per task #5645
 *              H.SALAHUDDIN -01 Mar 2014: Modified the WHEN clauses from 38 to 41 for backup contact number for text message  as per task # 5702				
 *              SABBASI - 04/18/2014; Added @VictimID as param to function fnGetBackupContatInfo   
 *				SABBASI - 04/26/2014; Added protocol name in the resultset. Feature #6104
 *				SABBASI - 05/03/2014; Passed v.VictimID in fnGetVictimContatInfoByPhoneType method instead of @VictimID. Bug #6154
 *			    SABBASI - 06/05/2014; Added Deleted flag check for Victim to make sure Victim is not archived. Task #6378.
 *				SOHAIL - 1 Nov 2014;converted priority from nvarchar to int in order to get the numerical ordering.Bug #6239
 *				SAHIB  - 04/07 2015; Returned victim phone number and email Task #8441.
 *				H.Salahuddin- 07-Aug-2015; Task #6239, Handled Priority field conversion to integer for Ordering. Also observed that
 *								     Order by clause was not ordering priority field converted into INT.
 *        SAHIB  - 22/08/2015; Returned Email for all victims associated with the offender of the provided alarm.
 *				SABBASI - 29/08/2015;  #8702. Get SMS and Phone address separately
 *        R.Cole - 5/02/2016: Readibility edit's to the Victim changes.
 *				H.Salahuddin 10-May-2016 Task# 8785 Victim App should play sounds when proximity alarm is generated
 * ******************************************************** */
ALTER PROCEDURE [dbo].[AlarmProtocolActionGetByAlarmIDOffenderID] (
    @AlarmID        INT,    
    @OffenderID     INT,
    @AgencyTime VARCHAR(20) = NULL    
)
AS  


DECLARE @VictimEmail nvarchar(MAX) = '',
        @VictimPhoneNumber nvarchar(100) = '',
        @VictimID INT,
        @RegistrationID NVARCHAR(2000) = ''

SET @VictimID = -1 -- default value

SELECT @VictimID = v.victimID, 
       @VictimEmail = v.Email, 
       @VictimPhoneNumber = ISNULL( vd.DevicePhoneNumber,''),
       @RegistrationID =  ISNULL(vd.RegistrationID,'')
FROM Victim v
  INNER JOIN VictimDevice vd ON vd.VictimDeviceID = v.VictimDeviceID
	INNER JOIN Victim_Offender_Event voe ON voe.VictimDeviceID = v.VictimDeviceID 
	INNER JOIN Alarm a ON voe.TrackerID = a.TrackerID AND voe.EventType = a.EventTypeID AND voe.EventTime = a.EventTime  
WHERE a.AlarmID = @AlarmID AND a.OffenderID = @OffenderID
  AND v.Deleted=0 AND vd.Deleted=0 

IF @VictimID > 0 
  SET @VictimID = @VictimID
ELSE  
  SET @VictimID = -1

-- // Main Query // --
SELECT DISTINCT 
aps.AlarmProtocolSetName,
apa.AlarmProtocolActionID, 
       apa.AlarmProtocolSetID, 
       apa.AlarmProtocolEventID,    
       apa.[Type], 
       --Note! this following field is just used to get Priority converted into INT. It has not use on UI.
       Case  PATINDEX('%[0-9]%', apa.[Priority]) When 1  Then CONVERT(int,apa.[Priority]) Else 0 End As PrioritySorted,
	     apa.Priority as [Priority],  
       apa.[From], 
       apa.[To],        
       apa.[Action],    
       CASE trackerpal.dbo.fnGetAlarmProtocolActionRecipientID(LTRIM(RTRIM(apa.Recipient)))
       -- Backup Contact
       WHEN 6 THEN trackerpal.dbo.fnGetBackupContatRecipient(apa.ContactInfo,o.OfficerID)                  
       -- Assigned Officer
       WHEN 1 THEN  LTRIM(RTRIM(apa.Recipient))+' '+ o.FirstName + ' ' + o.LastName        
       -- Agency      
       WHEN 2 THEN LTRIM(RTRIM(apa.Recipient))+' '+ag.Agency          
       -- Offender  
       WHEN 3 THEN  case offend.Victim when 1 then LTRIM(RTRIM(apa.Recipient))+' ' + offend2.Firstname + ' ' + offend2.LastName     
		                               else LTRIM(RTRIM(apa.Recipient))+' ' + offend.FirstName + ' ' + offend.LastName    
		            end                      
       --Victim
       WHEN 5 THEN LTRIM(RTRIM(apa.Recipient))+' '+  v.FirstName + ' ' + v.LastName
	    --NA
	    WHEN 4 THEN apa.Recipient
	          
       ELSE trackerpal.dbo.fnGetOtherrecipient(apa.Recipient)   
       END AS 'Recipient',               
       -- ContactInfo    
       CASE Trackerpal.dbo.fnGetAlarmProtocolActionContactInfoID(LTRIM(RTRIM(apa.ContactInfo)))									
			WHEN 12 THEN 
				CASE WHEN @VictimID > 0 THEN
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,@OffenderID,@VictimID),'')
				ELSE 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,@OffenderID,v.VictimID),'') 
				END                                                                       
			--Victim Mobile Phone #
			WHEN 13 THEN
				CASE WHEN @VictimID > 0 THEN 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,@OffenderID,@VictimID),'')  
				ELSE
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,@OffenderID,v.VictimID),'')  
				END                                      
			--Victim Device Phone # 
			--Commented by sahib, it is handled below                                    
			/*WHEN 20 THEN 
				CASE WHEN @VictimID > 0 THEN 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(10,@OffenderID,@VictimID),'')									 
				ELSE 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(10,@OffenderID,v.VictimID),'')	
				END*/
  			--Victim Home Phone #									  
			WHEN 14 THEN 
				CASE WHEN @VictimID > 0 THEN 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,@OffenderID,@VictimID),'')  
				ELSE
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,@OffenderID,v.VictimID),'')
				END                                                                                 
			--Victim Alternate Contact Work #
			WHEN 15 THEN 
				CASE WHEN @VictimID > 0 THEN 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,@OffenderID,@VictimID),'') 
				ELSE
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(2,@OffenderID,v.VictimID),'') 
				END                                        
			--Victim Alternate Contact Mobile #                                        
			WHEN 16 THEN 
				CASE WHEN @VictimID > 0 THEN 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,@OffenderID,@VictimID),'') 
				ELSE
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(3,@OffenderID,v.VictimID),'') 
				END                                      
			--Victim Alternate Contact Home #                                        
			WHEN 17 THEN 
				CASE WHEN @VictimID > 0 THEN 
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,@OffenderID,@VictimID),'')
				ELSE
					ISNULL(trackerpal.dbo.fnGetVictimContatInfoByPhoneType(1,@OffenderID,v.VictimID),'')
				END                                                                                   	
			--Officer Work (Office) Phone #									
			WHEN 1 THEN o.DayPhone                                                                      
			-- Officer Mobile Phone #
			WHEN 2 THEN o.MobilePhone                                                                                  
			--Officer Home Phone #
			WHEN 9 THEN o.EveningPhone                                        
			--On Call Phone #
			WHEN 3 THEN ag.OnCallPhone                                        
			-- Primary Agency Number                                       
			WHEN 35 THEN ag.Phone       	                                  
			-- Officer Pager #                                      
			WHEN 4 THEN o.Pager                                         
			-- On Call Pager #                                       
			WHEN 5 THEN ag.OnCallPager                                         
			-- Officer Email
			WHEN 6 THEN o.EmailAddress1                                         
			-- Officer Other Email
			WHEN 10 THEN o.EmailAddress2                                        
			-- Agency Email
			WHEN 11 THEN ag.EmailAddress                                         
			-- On Call Email
			WHEN 7 THEN ag.OnCallEmail                                         
			-- Offender Device
			WHEN 8 THEN NULL                                         
			-- Victim Device
			WHEN 20 THEN  
				CASE trackerpal.dbo.fnGetAlarmProtocolActionID(LTRIM(RTRIM(apa.[Action]))) 
					WHEN 1 THEN -- Call
						CASE WHEN @VictimID > 0 THEN 
							@VictimPhoneNumber
						ELSE
							ISNULL( vd.DevicePhoneNumber,'')
						END  
					WHEN 9 THEN -- Text Message
						CASE WHEN @VictimID > 0 THEN 
							@VictimPhoneNumber  +'@'+(SELECT SMSGatewayAddress FROM SMSGateway WHERE SMSGatewayID = vd.SMSGatewayID )
						ELSE
							ISNULL( vd.DevicePhoneNumber +'@'+(SELECT SMSGatewayAddress FROM SMSGateway WHERE SMSGatewayID = vd.SMSGatewayID ),'')
						END
					WHEN 10 THEN  -- Victim Alert -- GCM Notification
						CASE WHEN @VictimID > 0 THEN 
							@RegistrationID
						ELSE
							''
						END						
				   END                              
			-- Backup Contact1 Phone #
			WHEN 19 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(1,0,o.OfficerID),'')                                        
			-- Backup Contact2 Phone #
			WHEN 25 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(2,0,o.OfficerID) ,'')                                        
			-- Backup Contact3 Phone #
			WHEN 21 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(3,0,o.OfficerID) ,'')                                         
			-- Backup Contact4 Phone #
			WHEN 26 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(4,0,o.OfficerID),'')                                         
			-- Backup Contact1 Email
			WHEN 22 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(1,1,o.OfficerID),'')                                         
			-- Backup Contact2 Email
			WHEN 23 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(2,1,o.OfficerID) ,'')                                         
			-- Backup Contact3 Email
			WHEN 24 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(3,1,o.OfficerID) ,'')                                         
			-- Backup Contact4 Email
			WHEN 27 THEN isnull(trackerpal.dbo.fnGetBackupContatInfo(4,1,o.OfficerID)  ,'')                                         
			-- Backup Contact1 Text Message
			WHEN 38 THEN CASE trackerpal.dbo.fnGetBackupContatInfo(1,2,o.OfficerID)--Task # 5702                                            
							WHEN 'N/A' THEN '' -- the function call will always return N/A  in case of null
							ELSE
							isnull(trackerpal.dbo.fnGetBackupContatInfo(1,2,o.OfficerID)  ,'')                                         
							END
			-- Backup Contact2 Text Message
			WHEN 39 THEN CASE trackerpal.dbo.fnGetBackupContatInfo(2,2,o.OfficerID)--Task # 5702                                            
							WHEN 'N/A' THEN '' -- the function call will always return N/A  in case of null
							ELSE
							isnull(trackerpal.dbo.fnGetBackupContatInfo(2,2,o.OfficerID) ,'')                                         
							END                                         
		                                             
			-- Backup Contact3 Text Message
			WHEN 40 THEN CASE trackerpal.dbo.fnGetBackupContatInfo(3,2,o.OfficerID)--Task # 5702                                            
							WHEN 'N/A' THEN '' -- the function call will always return N/A  in case of null
							ELSE
							isnull(trackerpal.dbo.fnGetBackupContatInfo(3,2,o.OfficerID) ,'')                                         
							END
		    
			-- Backup Contact4 Text Message
			WHEN 41 THEN CASE trackerpal.dbo.fnGetBackupContatInfo(4,2,o.OfficerID)--Task # 5702                                            
							WHEN 'N/A' THEN '' -- the function call will always return N/A  in case of null
							ELSE
							isnull(trackerpal.dbo.fnGetBackupContatInfo(4,2,o.OfficerID) ,'')                                         
							END                        
		    WHEN 42 THEN  
				CASE WHEN @VictimID > 0 THEN 
					@VictimEmail
				ELSE
					v.Email
				END 
		    
			-- N/A
			WHEN 18 THEN apa.ContactInfo                                         
			-- Officer Text Message Add
			WHEN 36 THEN ISNULL( o.SMSAddress +'@'+(SELECT SMSGatewayAddress FROM SMSGateway WHERE SMSGatewayID = o.SMSGatewayID ),'')                                         
			-- Agency Text Message Add
			WHEN 37 THEN ISNULL(ag.SMSAddress +'@'+(SELECT SMSGatewayAddress FROM SMSGateway WHERE SMSGatewayID = ag.SMSGatewayID ),'')                                         
		    
		  ELSE trackerpal.dbo.fnGetOtherContacInfo('' + apa.Recipient + '/' + apa.ContactInfo + '')  
       END AS 'ContactInfo',     
       apa.Retry, apa.Note,
       CASE ISNULL(CONVERT(VARCHAR,oapa.CompletedDate),'0') WHEN '0' THEN 0 ELSE 1 END AS completed,    
       a.TrackerID    
FROM AlarmProtocolAction apa    
-- INNER JOIN to get protocol set Name
 INNER JOIN AlarmProtocolSet aps ON apa.AlarmProtocolSetID = aps.AlarmProtocolSetID
  INNER JOIN Offender_AlarmProtocolSet oaps ON apa.AlarmProtocolSetID = oaps.AlarmProtocolSetID 
         AND oaps.Deleted = 0    
  INNER JOIN AlarmProtocolEvent ape ON apa.AlarmProtocolEventID = ape.AlarmProtocolEventID    
  INNER JOIN Alarm a ON  ape.GatewayEventID = a.EventTypeID        
  INNER JOIN Offender offend ON a.OffenderID = offend.OffenderID    
  LEFT JOIN Offender offend2 ON offend.VictimAssociatedOffenderID = offend2.offenderid    
  INNER JOIN Offender_Officer oo ON offend.OffenderID = oo.OffenderID    
  LEFT JOIN dbo.OffenderTrackerActivation ota ON ota.offenderid= offend.VictimAssociatedOffenderID     
        AND ActivateDate = (select max(ActivateDate)     
                            from dbo.OffenderTrackerActivation 
                            where offenderid=offend.VictimAssociatedOffenderID)    
  INNER JOIN Officer o ON oo.OfficerID = o.OfficerID    
  INNER JOIN Agency ag ON o.AgencyID = ag.AgencyID    
  LEFT JOIN dbo.Operator_AlarmProtocolAction oapa ON a.alarmid = oapa.alarmid 
        and apa.AlarmProtocolActionID = oapa.AlarmProtocolActionID     
  LEFT JOIN Victim v ON offend.OffenderID = v.AssociatedOffenderID AND v.Deleted = 0
  LEFT JOIN VictimDevice vd ON vd.VictimDeviceID = v.VictimDeviceID
WHERE oaps.OffenderID = @OffenderID 
  AND a.AlarmID = @AlarmID 
  AND apa.Deleted = 0    
  AND (@VictimID = -1 OR v.VictimID =  @VictimID )
ORDER BY apa.type,Case  PATINDEX('%[0-9]%', apa.[Priority]) When 1  Then CONVERT(int,apa.[Priority]) Else 0  End
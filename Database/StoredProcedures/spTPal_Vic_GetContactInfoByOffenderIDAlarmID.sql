USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_GetContactInfoByOffenderIDAlarmID]    Script Date: 08/11/2016 07:51:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- FileName:	<spTPal_Vic_GetContactInfoByOffenderIDAlarmID.sql>
-- Author:		<Sahib Zar Khan>
-- Create date: <04 July 2015>
-- Modified By  H.Salahuddin 30 April 2016 Task # 8785. Added RegistrationID in the result set.
-- Description:	<Purpose of this sproc is to get Victim Contact Info>
-- Task:		<8424>
-- =============================================
ALTER PROCEDURE [dbo].[spTPal_Vic_GetContactInfoByOffenderIDAlarmID] 
	@OffenderID INT, 
	@AlarmID    INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT v.victimID As 'VictimID',
	v.FirstName,v.LastName, isNull(v.Email,'') As 'VictimEmail', 
	isNull(vd.DevicePhoneNumber,'') As 'DevicePhoneNumber',isNull(v.HomePhone1,'') As 'HomePhone1',
	isNull(v.HomePhone2,'') As 'HomePhone2',isNull(v.HomePhone3,'') As 'HomePhone2',
	ISNULL((SELECT SMSGatewayAddress FROM SMSGateway WHERE SMSGatewayID = vd.SMSGatewayID ),'') As 'SMSGateway',
	RegistrationID 
	FROM Victim v
	INNER JOIN VictimDevice vd ON vd.VictimDeviceID = v.VictimDeviceID
	INNER JOIN Victim_Offender_Event voe ON voe.VictimDeviceID = v.VictimDeviceID 
	INNER JOIN Alarm a ON voe.TrackerID = a.TrackerID AND voe.EventType = a.EventTypeID AND voe.EventTime = a.EventTime  
	
	WHERE a.AlarmID = @AlarmID AND a.OffenderID = @OffenderID
	AND v.Deleted=0 AND vd.Deleted=0 
END

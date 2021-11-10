USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Gtw_SmsAddress]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Gtw_SmsAddress]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Gtw_SmsAddress.sql
 * Created On: 14-Feb-2012
 * Created By: Sajid Abbasi
 * Task #:     #3114
 * Purpose:    To get the SMSGateway address for sending sms out.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Gtw_SmsAddress] 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT SMSGatewayID, 
       SMSGatewayAddress 
FROM SmsGateway
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Gtw_SmsAddress] TO db_dml;
GO
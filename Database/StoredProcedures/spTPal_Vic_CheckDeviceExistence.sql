USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_CheckDeviceExistence]    Script Date: 03/25/2016 06:26:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/* **********************************************************
 * FileName:   spTPal_Vic_CheckDeviceExistence.sql
 * Created On: 18-DEC-2015
 * Created By: SOHAIL
 * Task #:	   9131
 * Purpose:    Check if the device IMEI being registered already exists               
 * ********************************************************
-- ============================================= */
ALTER PROCEDURE [dbo].[spTPal_Vic_CheckDeviceExistence] 
	-- Add the parameters for the stored procedure here
	@DeviceIMEI  varchar(32)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
		SELECT FirstName,LastName FROM VictimDevice vd
		FULL OUTER JOIN Victim v ON vd.VictimDeviceID=v.VictimDeviceID
		WHERE DeviceIMEI = @DeviceIMEI AND vd.Deleted=0
END
USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Trk_GetNextEvent]    Script Date: 03/25/2016 10:02:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Trk_GetNextEvent.sql
 * Created On: 02/18/2016         
 * Created By: SABBASI
 * Task #:     #7945 
 * Purpose: Get next latest event location for Grace                   
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Trk_GetNextEvent]
	-- Add the parameters for the stored procedure here
	@DeviceID INT, 
	@EventTime BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    SELECT top 1 EventTime,Latitude,Longitude FROM Gateway.dbo.Events 
	WHERE DeviceID = @DeviceID 
	AND  EventTime > @EventTime 
	AND	 EventID < 270 
END

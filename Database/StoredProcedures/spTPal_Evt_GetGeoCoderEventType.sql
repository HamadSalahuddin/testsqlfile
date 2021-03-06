USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_GetGeoCoderEventType]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_GetGeoCoderEventType]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		SABBASI
-- Create date: 28-Sep-2011
-- Description:	Get Event Type IDs for those events which are to be processed for Geocoding
-- =============================================
CREATE PROCEDURE [dbo].[spTPal_Evt_GetGeoCoderEventType]
	
AS
BEGIN
		SELECT EventTypeID
		FROM Trackerpal.dbo.EventType 
		WHERE SO = 1 
		  AND OPR = 1 
		  AND BringOver = 1 
		  AND Visible = 1
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Evt_GetGeoCoderEventType] TO db_dml;
GO
USE [Gateway]
GO
/****** Object:  StoredProcedure [dbo].[spGW_DSS_GetDeviceProperties]    Script Date: 03/26/2016 06:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGW_DSS_GetDeviceProperties]
	@DeviceID	int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DeviceID,PropertyID,PropertyValue,[State],Notify,Dirty FROM DeviceProperties
    WHERE DeviceID = @DeviceID 
    AND PropertyID IN( '8008','8010','8012','8016','8017','8048','8202','8204','8205','8410','8411')
    ORDER BY PropertyID
END
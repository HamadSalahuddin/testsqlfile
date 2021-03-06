USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[GetAlarmProtocolActionRecipientOffender]    Script Date: 07/27/2011 15:27:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GetAlarmProtocolActionRecipientOffender] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT  aps.AlarmProtocolSetName ,aps.AlarmProtocolSetID, apa.alarmprotocolactionID
	FROM alarmprotocolaction apa 
		LEFT JOIN AlarmProtocolSet aps ON    
        apa.alarmprotocolsetID = aps.alarmprotocolsetID   
	WHERE recipient= 'Delincuente'--'offender'
END


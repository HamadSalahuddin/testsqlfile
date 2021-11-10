USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Alm_GetDispositionID]    Script Date: 11/09/2013 15:04:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Alm_GetDispositionID.sql
 * Created On: 13/7/2013
 * Created By: SABBASI
 * Task #:     #3472
 * Purpose:    Return disposition id. This will help in setting diregard checkbox
 * on protocol alarms scree.              
 *
 * Modified By:   
 * ******************************************************** */

ALTER PROCEDURE [dbo].[spTPal_Alm_GetDispositionID]  
 @DispositionAlarmID INT OUTPUT,  
 @AlarmID     INT   
AS
SELECT @DispositionAlarmID = AlarmDispositionID  
FROM Alarm  
WHERE AlarmID = @AlarmID 
  
IF @DispositionAlarmID IS NULL   
 SET @DispositionAlarmID =0

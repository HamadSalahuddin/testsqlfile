USE [Trackerpal]
GO

/****** Object:  StoredProcedure [dbo].[spSvc_Ofn_ProtocolsByAgencyID]    Script Date: 02/15/2012 23:07:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
/* ********************************************************** 
* FileName:   spSvc_Ofn_ProtocolsByAgencyID.sql  
* Created On: 09-Feb-2012            
* Created By: Sajid Sajjad Abbasi      
* Task #:     3020        
* Purpose:    Load only those protocols which have been changed or added recently  
* Modified By: R.Cole - 2/9/12: Removed single character aliases  
* ******************************************************** */
-- =============================================
CREATE PROCEDURE [dbo].[spSvc_Ofn_ProtocolsByAgencyID] 
(   @AgencyID INT )   
AS  
SELECT Offender_AlarmProtocolSet.Offender_AlarmProtocolSetID,   
       Offender_AlarmProtocolSet.OffenderID,   
       Offender_AlarmProtocolSet.AlarmProtocolSetID,   
       Offender_AlarmProtocolSet.CreatedByID  
FROM Offender_AlarmProtocolSet  
  INNER JOIN Offender ON Offender.OffenderID = Offender_AlarmProtocolSet.OffenderID  
WHERE Offender_AlarmProtocolSet.Deleted = 0    AND Offender.AgencyID = @AgencyID 

GO

GRANT EXECUTE ON [dbo].[spSvc_Ofn_ProtocolsByAgencyID] TO db_dml;
GO

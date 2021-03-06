USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetAllByAgnOfcDistID]    Script Date: 11/17/2014 1:20:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetAllByAgnOfcDistID.sql
 * Created On: 07/05/2013
 * Created By: SABBASI
 * Task #:     # 3172
 * Purpose:    Filter Offender list in Reports. 
 *
 * Modified By: R.Cole - 07/09/2013
 * Purpose:     Removed single character aliases, added GRANT stmt. 
 *              R.Cole - 07/17/2013
 *              Changed join to Distributor to an outer join.  
				D. Riding - 11/17/14
				Return DeviceType for active devices
 sample 
  exec [spTPal_Ofn_GetAllByAgnOfcDistID] 4, -1, 0 
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetAllByAgnOfcDistID] (
  @AgencyID INT = -1 ,
  @OfficerID INT = - 1,  
	@DistributorID INT 
)
AS
SELECT Offender.OffenderID,   
	     ISNULL(Offender.LastName, '')   + ', ' + ISNULL(Offender.FirstName, '') AS 'OffenderName',
		 aod.DeviceType as DeviceTypeID
FROM Offender_Officer oo
  INNER JOIN Offender ON oo.OffenderID = Offender.OffenderID  
  INNER JOIN Agency ON Agency.AgencyID = Offender.AgencyID
  LEFT OUTER JOIN Distributor ON Distributor.DistributorID = Agency.DistributorID
  INNER JOIN Officer ON Officer.OfficerID = oo.OfficerID 
  LEFT JOIN vwTPal_ActiveOffendersDevices aod ON aod.OffenderID = Offender.OffenderID		
 WHERE (@OfficerID < 0 OR (oo.OfficerID = @OfficerID))  
   AND (@AgencyID < 0 OR Agency.AgencyID = @AgencyID) 
   AND (Distributor.DistributorID = @DistributorID OR (@AgencyID > 0 AND @DistributorID < 1 ))
   AND (Offender.Deleted = 0)  
 ORDER BY 'OffenderName'




 select * from agency 
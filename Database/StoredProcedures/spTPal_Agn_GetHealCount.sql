USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Agn_GetHealCount]    Script Date: 03/25/2016 10:21:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sahib Zar Khan>
-- Create date: <05-Nov-2014>
-- Description:	<The store procedure is inteded to get HealCount for agency of an offender(@offenderid>

-- Modified By: R.Cole - 12/11/2014: Removed single character aliases.
--              Sahib - 12/03/2016: Added Logic for Returning Offender Interval along with Heal count
-- =============================================
ALTER PROCEDURE  [dbo].[spTPal_Agn_GetHealCount] (
	@offenderID INT
)	
AS
BEGIN
  
  DECLARE @TimeSeconds INT

  EXEC ReportingIntervalGetByOffenderID @TimeSeconds OUTPUT, @OffenderID 
  
  SELECT Agency.HealCount, 
         @TimeSeconds AS ReportingInterval
	FROM Agency
	  INNER JOIN Offender ON Agency.AgencyID = Offender.AgencyID
	         AND Offender.Deleted = 0
	         AND Offender.OffenderID = @offenderID
  ORDER BY Agency.AgencyID
END

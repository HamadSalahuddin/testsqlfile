USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[OffenderGetAllByAgencyID]    Script Date: 03/24/2010 17:40:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 1-Mar-2010
-- Description:	This procedure gets us Offender info for Offenders
-- belonging to the given agency provided Offender is not deleted.
-- =============================================
CREATE PROCEDURE [dbo].[OffenderGetAllByAgencyID]
	
	@agencyID int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT o.OffenderID, o.FirstName, o.LastName
	FROM Offender o
	INNER JOIN Agency a ON
	a.AgencyID = o.AgencyID
	AND o.Deleted = 0
	AND a.AgencyID = @agencyID
ORDER BY o.OffenderID
END

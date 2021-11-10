USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleOffenderGetRulesByOffenderID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleOffenderGetRulesByOffenderID]
GO

USE TrackerPal
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 18-Dec-2009
-- Description:	This procedure gets all the georules from GeoRule_Offender table for 
-- given offender
-- =============================================
CREATE PROCEDURE GeoRuleOffenderGetRulesByOffenderID 
        @OffenderID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  
SELECT GeoRuleID FROM GeoRule_Offender
WHERE OffenderID = @OffenderID
	
END
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleOffenderGetRulesByOffenderID ] TO db_dml;
GO

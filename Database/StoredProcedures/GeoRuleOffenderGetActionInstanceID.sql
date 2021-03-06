USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleOffenderGetActionInstanceID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleOffenderGetActionInstanceID]
GO

USE TrackerPal
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 17-Dec-2009
-- Description:	This stored procedure returns values 
-- =============================================
CREATE PROCEDURE [dbo].[GeoRuleOffenderGetActionInstanceID]
	-- Add the parameters for the stored procedure here
	@GeoRuleID int,
    @ActionInstanceID bigint output
	
AS
BEGIN
	SET NOCOUNT ON;
SELECT  top 1 @ActionInstanceID = ActionInstanceID FROM GeoRule_Offender 
WHERE GeoRuleID = @GeoRuleID
END


GO
--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleOffenderGetActionInstanceID] TO db_dml;
GO
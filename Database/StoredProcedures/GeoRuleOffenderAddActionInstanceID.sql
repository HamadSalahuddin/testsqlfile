USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleOffenderAddActionInstanceID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleOffenderAddActionInstanceID]
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
-- Create date: 16-Dec-2009
-- Description:	This procedure adds ActionInstanceID for the georule that are uploaded.
-- =============================================
CREATE PROCEDURE GeoRuleOffenderAddActionInstanceID
	@OffenderID int,
    @ActionInstanceID bigint
AS
BEGIN

	SET NOCOUNT ON;

    UPDATE GeoRule_Offender 
	SET ActionInstanceID = @ActionInstanceID
WHERE
	OffenderID = @OffenderID

END
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleOffenderAddActionInstanceID] TO db_dml;
GO

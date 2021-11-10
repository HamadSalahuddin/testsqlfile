USE Trackerpal
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GetGeoRuleOffenderAddActionInstanceID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetGeoRuleOffenderAddActionInstanceID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 17-Dec-2009
-- Description:	This stored procedure returns values 
-- =============================================

CREATE PROCEDURE [dbo].[GetGeoRuleOffenderAddActionInstanceID] (
  @GeoRuleID INT,
  @ActionInstanceID BIGINT OUTPUT
)
	
AS
BEGIN
	SET NOCOUNT ON;
  SELECT @ActionInstanceID = ActionInstanceID 
  FROM GeoRule_Offender 
  WHERE GeoRuleID = @GeoRuleID
END
GO

GRANT EXECUTE ON GetGeoRuleOffenderAddActionInstanceID TO db_dml;
GO


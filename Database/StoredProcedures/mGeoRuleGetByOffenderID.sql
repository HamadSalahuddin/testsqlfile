USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mGeoRuleGetByOffenderID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mGeoRuleGetByOffenderID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date:02-Dec-2010
-- Description:	We want to get GeoRules by OffenderID.
-- =============================================
CREATE PROCEDURE [dbo].[mGeoRuleGetByOffenderID] (
	@OffenderID INT 
)
AS
BEGIN
 	SELECT GeoRule_Offender.GeoruleID			
	FROM GeoRule_Offender 	
	WHERE GeoRule_Offender.OffenderID = @OffenderID
END
GO

GRANT EXECUTE ON [dbo].[mGeoRuleGetByOffenderID] TO db_dml;
GO
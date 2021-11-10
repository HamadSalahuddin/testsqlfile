/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 18-Dec-2009
-- Description:	This procedure gets all the georules from GeoRule_Offender table for 
-- given offender
-- =============================================
CREATE PROCEDURE [GeoRuleOffenderGetRulesByOffenderID] 
        @OffenderID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  
    SELECT GeoRuleID 
    FROM GeoRule_Offender
    WHERE OffenderID = @OffenderID	
END

GO
GRANT EXECUTE ON [GeoRuleOffenderGetRulesByOffenderID] TO [db_dml]
GO

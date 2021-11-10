USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GeoRuleOffenderSetAreaID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleOffenderSetAreaID]
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
-- Create date: 22-Dec-2009
-- Description:	This procedure iterates through all the GeoRules in GeoRule_Offender
-- table created under 5.36 and gives a unique AreaID to them.
-- =============================================
CREATE PROCEDURE GeoRuleOffenderSetAreaID
		
AS
BEGIN
	
	SET NOCOUNT ON;
DECLARE @GeoRuleID int, @counter int
SET @counter = 1
-- Create Cursor
DECLARE GeoRuleOffenderSetAreaID Cursor fast_forward
FOR SELECT GeoRuleID From GeoRule_Offender WHERE AreaID = -1
-- Open Cursor

Open GeoRuleOffenderSetAreaID 
FETCH next FROM GeoRuleOffenderSetAreaID INTO @GeoRuleID

WHILE @@fetch_status = 0 
BEGIN

UPDATE GeoRule_Offender SET AreaID = @counter WHERE GeoRuleID = @GeoRuleID
SET @counter = @counter + 1
FETCH Next FROM GeoRuleOffenderSetAreaID INTO @GeoRuleID

END

-- Close Cursor
Close GeoRuleOffenderSetAreaID
DEALLOCATE GeoRuleOffenderSetAreaID

END
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[GeoRuleOffenderSetAreaID] TO db_dml;
GO

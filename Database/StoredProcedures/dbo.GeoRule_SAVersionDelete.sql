/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
-- =============================================
-- Author:		<Sajid Abbasi>
-- Create date: <20-Nov-2009>
-- Description:	<This stored procedure is a wraper on GeoRuleDelete2 stored procedure
-- It makes calls for all the GeoRules IDs that are going to be modified.>
-- =============================================
CREATE PROCEDURE [GeoRule_SAVersionDelete]
@geoRulesID Varchar(MAX)	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    set ANSI_NULLS ON
    set QUOTED_IDENTIFIER ON
-- SABBASI
DECLARE @id int
DECLARE MyCursor cursor fast_forward 
For
SELECT number from GetTableFromListId( @geoRulesID )

Begin TRAN 
Open MyCursor
Fetch next From MyCursor
INTO @id
 
WHILE @@fetch_status = 0 AND @id > 0
Begin
  -- Perform Operations
  Exec GeoRuleDelete2 @id
  
  -- Advance the Cursor
  Fetch next From MyCursor
  INTO @id
End
 
Close MyCursor
DEALLOCATE MyCursor
IF @@ERROR <> 0
BEGIN
ROLLBACK Tran
END
 COMMIT TRAN  
Return 0
-- SABBASI
    
END
GO
GRANT EXECUTE ON [GeoRule_SAVersionDelete] TO [db_dml]
GO

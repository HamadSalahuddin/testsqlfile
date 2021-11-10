USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OffenseTypeGetAll]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OffenseTypeGetAll]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   OffenseTypeGetAll.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc  
 * Task #:     <Redmine #>      
 * Purpose:    Return the Offense Types to a dropdown               
 *
 * Modified By: R.Cole - 09/21/2010: Brought up to Standard
 * ******************************************************** */

CREATE PROCEDURE [dbo].[OffenseTypeGetAll] 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT OffenseTypeID,
         OffenseType
	FROM OffenseType
  ORDER BY OffenseTypeID
END
GO

GRANT EXECUTE ON [dbo].[OffenseTypeGetAll] TO db_dml;
GO
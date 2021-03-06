USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GetExistingFromAddDaylightProcess]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetExistingFromAddDaylightProcess]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   GetExistingFromAddDaylightProcess.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     <Redmine #>      
 * Purpose:                   
 *
 * Modified By: 
 * ******************************************************** */
CREATE PROCEDURE [dbo].[GetExistingFromAddDaylightProcess] 
AS
SELECT DaylightUpdateProgressID,
       TrackerID,
       OffenderID
FROM DaylightUpdateProgress
WHERE FileID IS NULL
ORDER BY DayLightUpdateProgressID
GO

GRANT EXECUTE ON [dbo].[GetExistingFromAddDaylightProcess] TO db_dml;
GO 

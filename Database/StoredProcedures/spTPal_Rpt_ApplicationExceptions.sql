USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_ApplicationExceptions]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_ApplicationExceptions]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_ApplicationExceptions.sql
 * Created On: 08/08/2012
 * Created By: R.Cole
 * Task #:     Redmine #      
 * Purpose:    Return data to an automated report for the 
 *             dev team to isolate recurring application
 *             exceptions(errors)               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_ApplicationExceptions] (
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* *** Dev Use *** *
DECLARE @StartDate DATETIME,
        @EndDate DATETIME

SET @StartDate = NULL
SET @EndDate = NULL
* *** End Dev *** */

-- // Handle NULL Dates // --
IF @StartDate IS NULL OR @EndDate IS NULL
  BEGIN
    SET @StartDate = DATEADD(HOUR, -1, GETDATE())
    SET @EndDate = GETDATE()
  END
   
-- // Main Query // --
SELECT DISTINCT LogErrors.ID, 
       LogErrorTypes.Name AS [Type],
--       LogErrorActions.Name,
       dbo.fnUTCToMST(LogErrors.TimeStamp) AS [Time (MT)],
       LogErrors.ClassName,
       LogErrors.FunctionName,
       LogErrors.Message,
       LogErrors.Exception
FROM LogErrors 
  LEFT OUTER JOIN LogErrorTypes ON LogErrors.TypeID = LogErrorTypes.ID
  LEFT OUTER JOIN LogErrorTypesActions ON LogErrorTypes.ActionID = LogErrorTypesActions.ActionID
  LEFT OUTER JOIN LogErrorActions ON LogErrorTypesActions.ActionID = LogErrorActions.ID
WHERE LogErrors.TimeStamp BETWEEN @StartDate AND @EndDate
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_ApplicationExceptions] TO db_dml;
GO
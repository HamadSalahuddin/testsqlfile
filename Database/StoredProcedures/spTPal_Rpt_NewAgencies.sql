USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_NewAgencies]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_NewAgencies]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_NewAgencies.sql
 * Created On: 10/12/2012
 * Created By: R.Cole
 * Task #:     3715 
 * Purpose:    Return a list of agencies created between
 *             a user specified start and end date               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_NewAgencies] (
  @StartDate DATETIME,
  @EndDate DATETIME
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @UTCOffset INT

SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
   
-- // Main Query // --
SELECT Agency.Agency,
       CONVERT(CHAR(8), DATEADD(MI, @UTCOffset,CreatedDate), 1) AS 'CreatedDate',
       CONVERT(CHAR(8), @StartDate,1) AS StartDate,
       CONVERT(CHAR(8), @EndDate,1) AS EndDate
FROM Agency
WHERE Deleted = 0
  AND DATEADD(MI, @UTCOffset,CreatedDate) BETWEEN @StartDate AND @EndDate
ORDER BY Agency,
         CreatedDate
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_NewAgencies] TO db_dml;
GO
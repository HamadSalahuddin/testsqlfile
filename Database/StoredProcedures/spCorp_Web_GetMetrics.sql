USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spCorp_Web_GetMetrics]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spCorp_Web_GetMetrics]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spCorp_Web_GetMetrics.sql
 * Created On: 06/10/2010         
 * Created By: R.Cole  
 * Task #:     1006      
 * Purpose:    Returns metrics for display on the Corporate
 *             web site               
 *
 *      TODO: Case Stmt if we wind up with a few more Metrics
 * Modified By: R.Cole - 6/11/2010 - Added Output Var so HTML
 *                page doesn't have do deal with a DataTable.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spCorp_Web_GetMetrics] (
  @MetricType VARCHAR(40) = NULL,  
  @Metric INT OUTPUT
) 
AS
SET NOCOUNT ON;

-- // OffenderCount // --
IF (@MetricType IS NULL OR @MetricType LIKE 'OffenderCount')
  BEGIN
    SELECT @Metric = COUNT(OffenderID) 
    FROM TrackerPal.dbo.Offender
  END
  
-- // AlarmCount // -- 
IF (@MetricType LIKE 'AlarmCount')
  BEGIN
    SELECT @Metric = COUNT(AlarmID) 
    FROM TrackerPal.dbo.Alarm
  END
  
GO

-- // Grant Permissions // --
GRANT EXECUTE ON [dbo].[spCorp_Web_GetMetrics] TO db_dml;
GO
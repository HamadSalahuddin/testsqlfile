USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_DeviceVolumeDashboard_PuertoRico]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_DeviceVolumeDashboard_PuertoRico]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_DeviceVolumeDashboard_PuertoRico.sql
 * Created On: 01/30/2013         
 * Created By: R.Cole  
 * Task #:     #3901      
 * Purpose:    Return data to the dashboard.              
 *
 * Modified By: R.Cole - 2/20/2013: Ported to return Puerto
 *              Rico data only.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_DeviceVolumeDashboard_PuertoRico] (
  @DataDate DATETIME
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Main Query // --
SELECT Active,
       Inactive,
       RMA,
       Reported
FROM DeviceVolumes_PuertoRico
WHERE DataDate = @DataDate
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_DeviceVolumeDashboard_PuertoRico] TO db_dml;
GO
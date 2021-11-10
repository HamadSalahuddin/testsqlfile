USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_DeviceVolumeDashboard]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_DeviceVolumeDashboard]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_DeviceVolumeDashboard.sql
 * Created On: 01/30/2013         
 * Created By: R.Cole  
 * Task #:     #3901      
 * Purpose:    Return data to the dashboard.              
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_DeviceVolumeDashboard] (
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
FROM DeviceVolumes
WHERE DataDate = @DataDate
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_DeviceVolumeDashboard] TO db_dml;
GO
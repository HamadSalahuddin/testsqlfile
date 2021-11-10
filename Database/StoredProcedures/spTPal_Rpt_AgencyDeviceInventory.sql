USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AgencyDeviceInventory]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AgencyDeviceInventory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AgencyDeviceInventory.sql
 * Created On: 8/22/2011        
 * Created By: R.Cole  
 * Task #:     #2627      
 * Purpose:    Return data for the AgencyDeviceInventory Report              
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AgencyDeviceInventory] (
  @AgencyID INT 
) 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Set Date to the previous day // --   
DECLARE @RunDate CHAR(10)
SET @RunDate = DATEADD(DAY, -1,GETDATE())
   
-- // Main Query // --
SELECT DISTINCT Agency.Agency AS 'Agency',
       SUM((CASE WHEN svc.optionalserviceflag = 0 THEN 1 ELSE 0 END)) AS 'TotalAssignedDevices',
       SUM((CASE WHEN svc.activeflag = 'Y' THEN 1 ELSE 0 END)) AS 'ActiveDevices',
       SUM((CASE WHEN svc.activeflag = 'N' AND bd.RMAFlag = 'N'THEN 1 ELSE 0 END)) AS 'InactiveDevices',
       SUM((CASE WHEN bd.RMAFlag = 'Y' AND svc.activeflag = 'N' THEN 1 ELSE 0 END)) AS 'RMADevices',
       CONVERT(CHAR(10), @RunDate, 110) AS [RunDate] -- Strip off time segment
FROM Reporthelper.dbo.BillingDay bd
	INNER JOIN Agency ON bd.AgencyID = Agency.AgencyID
	INNER JOIN ReportHelper.dbo.Services svc ON bd.ServiceID = svc.ServiceID
	LEFT OUTER JOIN ReportHelper.dbo.Contracts con ON bd.AgencyID = con.Agency
WHERE bd.BillingDay = CONVERT(CHAR(10), @RunDate, 110)
	AND bd.Billable = 1
	AND bd.IsDemo = 0
	AND svc.OptionalServiceFlag = 0
	AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)
	AND bd.AgencyID = @AgencyID
GROUP BY Agency.Agency
ORDER BY Agency.Agency
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AgencyDeviceInventory] TO db_dml;
GO
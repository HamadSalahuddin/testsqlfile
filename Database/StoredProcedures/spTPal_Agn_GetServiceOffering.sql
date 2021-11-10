USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTpal_Agn_GetServiceOffering]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Agn_GetServiceOffering]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Agn_GetServiceOffering.sql
 * Created On: 02/13/2012         
 * Created By: R.Cole 
 * Task #:     
 * Purpose:    Return data to a TrackerPal v2 Offender QuickAdd
 *             dropdown               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Agn_GetServiceOffering] (
  @AgencyID INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  

--DECLARE @AgencyID INT
--SET @AgencyID = 1  
   
-- // Main Query // --
SELECT BillingService.ID AS BillingServiceID,
       refBillingServiceType.BillingServiceTypeName,
       svc.ServiceName
FROM BillingService              
  INNER JOIN refBillingServiceType ON refBillingServiceType.ID = BillingService.BillingServiceTypeID            
  INNER JOIN BillingServiceOption ON BillingService.ID = BillingServiceOption.BillingServiceID            
  INNER JOIN BillingServiceOptionReportingInterval bsori ON BillingServiceOption.ID = bsori.BillingServiceOptionID            
  INNER JOIN refServiceOptionReportingInterval rsori ON bsori.ReportingIntervalID = rsori.ID            
  INNER JOIN ClassicBillingService ON BillingService.ID = ClassicBillingService.BillingServiceID   
  INNER JOIN [Services] svc on ClassicBillingService.ServiceID = svc.ServiceID         
  LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID            
WHERE BillingService.AgencyID = @AgencyID
  AND BillingService.Disabled <> 1

UNION

SELECT BillingService.ID AS BillingServiceID,
       refBillingServiceType.BillingServiceTypeName,
       svc.ServiceName
FROM BillingService
  INNER JOIN refBillingServiceType ON refBillingServiceType.ID = BillingService.BillingServiceTypeID            
  INNER JOIN ClassicBillingService ON BillingService.ID = ClassicBillingService.BillingServiceID 
  INNER JOIN [Services] svc on ClassicBillingService.ServiceID = svc.ServiceID
  LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID            
WHERE ClassicBillingService.ServiceID = 4 
  AND BillingService.AgencyID = @AgencyID
  AND BillingService.Disabled <> 1
--ORDER BY DisplayOrder

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Agn_GetServiceOffering] TO db_dml;
GO
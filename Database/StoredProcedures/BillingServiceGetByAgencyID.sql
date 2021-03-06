USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[BillingServiceGetByAgencyID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BillingServiceGetByAgencyID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   BillingServiceGetByAgencyID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     
 * Purpose:    Returns data about ann agencies billing services               
 *
 * Modified By: S.Abbasi - 18-Jan-2011: Added two fields to
 *                return data about disabled service plans
 *              R.Cole - 18-Jan-2011: Refactored for readability
 *                and to bring into code compliance.
 *              Unknown - Unknown: New field was added and not
 *                documented.
 *              R.Cole - 09-Jan-2013: Added check for disabled
 *                reporting interval per #3840
 * ******************************************************** */
CREATE PROCEDURE [dbo].[BillingServiceGetByAgencyID] (
    @AgencyID INT
)
AS        
SET NOCOUNT ON;    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
    
-- // Get data from Active, Passive and Passive+ services // --   
SELECT BillingService.ID BillingServiceID,
       ISNULL(BillingService.[Disabled],0) AS [Disabled], 
       refBillingServiceType.BillingServiceTypeName,
       BillingService.BillingServiceTypeID, 
       BillingServiceOption.ID BillingServiceOptionID,
       BillingServiceOption.IsRequired, 
       BillingServiceOption.IsOptional, 
       bsori.ReportingIntervalID, 
       rsori.[Name],
       rsori.TimeSeconds,
       bsori.Cost,
       rsori.DisplayOrder,
       EArrestService.ID AS eArrestServiceID, 
       EArrestService.BeaconLimit, 
       EArrestService.PricePerBeacon,
       StartDateTime, 
       ClassicBillingService.ServiceID, 
       NULL AS Rate,
       Services.ServiceName           
FROM BillingService              
  INNER JOIN refBillingServiceType ON refBillingServiceType.ID = BillingService.BillingServiceTypeID            
  INNER JOIN BillingServiceOption ON BillingService.ID = BillingServiceOption.BillingServiceID            
  INNER JOIN BillingServiceOptionReportingInterval bsori ON BillingServiceOption.ID = bsori.BillingServiceOptionID            
  INNER JOIN refServiceOptionReportingInterval rsori ON bsori.ReportingIntervalID = rsori.ID            
  INNER JOIN ClassicBillingService ON BillingService.ID = ClassicBillingService.BillingServiceID            
  LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID 
  INNER JOIN Services ON ClassicBillingService.ServiceID = Services.ServiceID           
WHERE BillingService.AgencyID = @AgencyID
  AND BillingServiceOption.Deleted = 0

UNION    

-- // Get Earrest data // --
SELECT BillingService.ID BillingServiceID,
       ISNULL(BillingService.[Disabled],0) AS [Disabled], 
       refBillingServiceType.BillingServiceTypeName,
       BillingService.BillingServiceTypeID, 
       NULL BillingServiceOptionID,
       NULL IsRequired, 
       NULL IsOptional,
       NULL ReportingIntervalID, 
       NULL [Name],
       NULL TimeSeconds,
       NULL Cost,
       NULL DisplayOrder,             
       EArrestService.ID AS eArrestServiceID, 
       EArrestService.BeaconLimit, 
       EArrestService.PricePerBeacon,
       StartDateTime, 
       ClassicBillingService.ServiceID, 
       EArrestService.Rate,
       Services.ServiceName         
FROM BillingService
  INNER JOIN refBillingServiceType ON refBillingServiceType.ID = BillingService.BillingServiceTypeID            
  INNER JOIN ClassicBillingService ON BillingService.ID = ClassicBillingService.BillingServiceID            
  LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID
  INNER JOIN Services ON ClassicBillingService.ServiceID = Services.ServiceID            
WHERE ClassicBillingService.ServiceID = 4 
  AND BillingService.AgencyID = @AgencyID
ORDER BY DisplayOrder
GO

GRANT EXECUTE ON [dbo].[BillingServiceGetByAgencyID] TO db_dml;
GO
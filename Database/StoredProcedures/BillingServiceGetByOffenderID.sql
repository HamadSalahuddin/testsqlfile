USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[BillingServiceGetByOffenderID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BillingServiceGetByOffenderID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   BillingServiceGetByOffenderID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     
 * Purpose:    Returns data about an agencies billing services               
 *
 * Modified By: R.Cole - 09-Jan-2013: Refactored for readability
 *                and to bring into code compliance. 
 * ******************************************************** */
CREATE PROCEDURE [BillingServiceGetByOffenderID] (
  @OffenderID INT
)
AS    
SET NOCOUNT ON;    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;        

SELECT offs.BillingServiceID AS OffOptBillServID,         
       obsoo.BillingServiceOptionID AS OptBillServOptOffID, 
       es.ID AS eArrestServiceID, 
       es.BeaconLimit,  
       obsoo.BeaconCount, 
       ebs.BillingStatus, 
       cbs.ServiceID      
FROM BillingService   
  INNER JOIN Offender ON Offender.AgencyID = BillingService.AgencyID  
  LEFT OUTER JOIN dbo.BillingServiceOption bso ON bso.BillingServiceID = BillingService.ID  
  LEFT OUTER JOIN dbo.OffenderOptionalBillingService offs ON offs.OffenderID = Offender.OffenderID AND BillingService.ID = offs.BillingServiceID  
  LEFT OUTER JOIN dbo.OptionalBillingServiceOptionOffender obsoo ON obsoo.OffenderID = Offender.OffenderID AND obsoo.BillingServiceOptionID = bso.ID  
  LEFT OUTER JOIN dbo.ClassicBillingService cbs ON BillingService.ID = cbs.BillingServiceID  
  LEFT OUTER JOIN dbo.EArrestService es ON cbs.ID = es.ClassicBillingServiceID         
  LEFT OUTER JOIN (Select OffenderID, MAX(ID) AS LastID FROM EArrestBillingStatus GROUP BY OffenderID) ebs1 ON ebs1.OffenderID = Offender.OffenderID  
  LEFT OUTER JOIN EarrestBillingStatus ebs ON ebs.ID = ebs1.LastID  
WHERE Offender.OffenderID = @OffenderID
  AND (offs.BillingServiceID IS NOT NULL OR obsoo.BillingServiceOptionID IS NOT NULL)  
  AND (NOT(obsoo.BillingServiceOptionID IS NULL AND cbs.ServiceID != 4))
GO

GRANT EXECUTE ON [BillingServiceGetByOffenderID] TO [db_dml]
GO

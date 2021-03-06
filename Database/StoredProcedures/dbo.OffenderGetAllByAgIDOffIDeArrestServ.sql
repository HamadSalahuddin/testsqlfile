/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetAllByAgIDOffIDeArrestServ]   
@AgencyID INT,  
@OfficerID INT,  
@RoleID  INT  

AS  


BEGIN 
SELECT distinct o.OffenderID  ,    ISNULL(o.LastName + ', ', '') + ISNULL(o.FirstName, '') AS 'OffenderName', o.LastName, o.FirstName    
FROM Offender o  (NOLOCK)     
left JOIN Offender_Officer  oo (NOLOCK) ON o.OffenderID = oo.OffenderID     
left JOIN dbo.OffenderOptionalBillingService offs ON o.OffenderID = offs.OffenderID
left join dbo.ClassicBillingService cbs on cbs.billingServiceId = offs.BillingServiceid
left join dbo.eArrestService eas on eas.classicBillingServiceID =  cbs.id
left join dbo.BillingService bs on bs.AgencyID = o.AgencyID and billingservicetypeid=1
left join dbo.ClassicBillingService cbs2 on cbs2.billingServiceId = bs.id
left join dbo.eArrestService eas2 on eas2.classicBillingServiceID =  cbs2.id
left join (Select OffenderID, MAX(ID) As lastid From EArrestBillingStatus Group BY Offenderid) ebs1 ON ebs1.OffenderID=o.OffenderID
LEFT JOIN EarrestBillingStatus ebs ON ebs.id = ebs1.lastid

WHERE(      (       (@RoleID = 2 OR @RoleID = 3)       
AND        (o.AgencyID = @AgencyID)      )
      OR       (       (        (@AgencyID<=0)        
or        (o.AgencyID = @AgencyID)       )       
AND(        (@OfficerID<=0)      
  or        (oo.OfficerID = @OfficerID)       )      )     )           
 AND o.Deleted = 0 AND o.Victim = 0  
and (eas2.id is not null or eas.id is not null)  
and (ebs.BillingStatus='True')
ORDER BY o.LastName, o.FirstName    
 END

GO
GRANT EXECUTE ON [OffenderGetAllByAgIDOffIDeArrestServ] TO [db_dml]
GO

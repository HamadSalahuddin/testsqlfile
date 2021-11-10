/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetAllByAgencyIDOfficerID]   
 @AgencyID INT,  
@OfficerID INT,  
@RoleID  INT,  
@UserID int = -1  
AS       

IF @RoleID <> 6    
BEGIN    

	SELECT o.OffenderID  ,
		ISNULL(o.LastName + ', ', '') + 
		ISNULL(o.FirstName, '') AS 'OffenderName',
	 o.AgencyID,
	 oo.OfficerID,
   	ISNULL(offi.LastName, '')   + ', ' +  
	ISNULL(offi.MiddleName, '') + ' ' +  
	ISNULL(offi.FirstName, '') AS 'OfficerName',		
	a.Agency 
	FROM Offender o  (NOLOCK)     
	left JOIN Offender_Officer  oo (NOLOCK) ON o.OffenderID = oo.OffenderID     
	INNER JOIN agency a on o.AgencyID = a.AgencyID           
	left JOIN Officer offi ON offi.officerID = oo.Officerid 
	WHERE(      (       (@RoleID = 2 OR @RoleID = 3)       
	AND        (o.AgencyID = @AgencyID)      )      
	OR       (       (        (@AgencyID<=0)        
	or        (o.AgencyID = @AgencyID)       )       
	AND(        (@OfficerID<=0)        
	or        (oo.OfficerID = @OfficerID)       )      )     )            
	AND o.Deleted = 0 AND o.Victim = 0    
	ORDER BY o.LastName, o.FirstName     

END  
ELSE 
   BEGIN   
 SELECT o.OffenderID  ,
		de.UserID,
		ISNULL(o.LastName + ', ', '') + 
		ISNULL(o.FirstName, '') AS 'OffenderName',   
	o.AgencyID,
	oo.OfficerID,
	ISNULL(offi.LastName, '')   + ', ' +  
	 ISNULL(offi.MiddleName, '') + ' ' +  
	ISNULL(offi.FirstName, '') AS 'OfficerName',		
	a.Agency 
 FROM Offender o  (NOLOCK)    
INNER JOIN agency a on o.AgencyID = a.AgencyID    
INNER JOIN distributoremployee de on a.DistributorID=de.DistributorID AND de.UserID=@UserID    
left JOIN Offender_Officer  oo (NOLOCK) ON o.OffenderID = oo.OffenderID     
left JOIN Officer offi ON offi.officerID = oo.Officerid 
WHERE o.Deleted = 0 AND o.Victim = 0    ORDER BY o.LastName, o.FirstName     END 
GO
GRANT VIEW DEFINITION ON [OffenderGetAllByAgencyIDOfficerID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderGetAllByAgencyIDOfficerID] TO [db_dml]
GO
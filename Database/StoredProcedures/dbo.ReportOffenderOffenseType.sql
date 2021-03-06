/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportOffenderOffenseType] 

 @StartDate  DateTime,   
 @EndDate  DateTime,   
 @OffenseSubTypeID  INT,   
 @OfficerID      INT,   
 @SO    INT,   
 @OPR   INT,   
 @TimeZoneOffset INT,
 @AgencyId    INT

AS   

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
  

SELECT   
            distinct  
            o.OffenderID,   
            ag.Agency,      
            ISNULL(offi.FirstName + ' ', '') +   
            ISNULL(offi.MiddleName + ' ', '') +   
            ISNULL(offi.LastName, '') AS 'OfficerName',   
            ISNULL(o.FirstName + ' ', '') +    
            ISNULL(o.MiddleName + ' ', '') +   
            ISNULL(o.LastName, '') AS 'OffenderName',   
            ot.OffenseType,   
            ost.SubType

        FROM Offender o   
        left join Offender_Officer ofof on o.OffenderID = ofof.OffenderID   
        left join OffenderTrackerActivation ota on o.offenderid = ota.offenderID       
        left join Officer offi on ofof.OfficerID = offi.OfficerID   
        left join OffenseType ot on o.OffenseTypeID=ot.OffenseTypeID   
        left join OffenseSubType ost on ost.OffenseSubTypeId= o.OffenseSubTypeId   
        left join Agency ag on ag.AgencyID=o.agencyID   

        Where  ota.IsDemo=0
                AND 
                 
                      DATEADD ( mi, @TimeZoneOffset,ota.ActivateDate)< @EndDate
      AND (DATEADD ( mi, @TimeZoneOffset,deactivatedate) >= @StartDate
            OR DATEADD ( mi, @TimeZoneOffset,deactivatedate) IS NULL)
				

                        and 
                        ( 
                              o.agencyID  = @AgencyID 
                        )     
                        and   
                (                         
                     (o.OffenseSubTypeID = @OffenseSubTypeID)   
                      or   
                     (@OffenseSubTypeID=-1)   
                )   
	    and   
                (                         
                     (ofof.OfficerID = @OfficerID)   
                      or   
                     (@OfficerID=-1)   
                )   

ORDER BY SubType,OffenderName   
GO
GRANT EXECUTE ON [ReportOffenderOffenseType] TO [db_dml]
GO

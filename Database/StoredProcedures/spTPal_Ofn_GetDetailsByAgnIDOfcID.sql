USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetDetailsByAgnIDOfcID]    Script Date: 01/01/2015 12:02:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetDetailsByAgnIDOfcID.sql
 * Created On: 23-Apr-2010
 * Created By: Sajid Abbasi
 * Task #:     
 * Purpose:    Get list of Offenders based on Agency IDs and 
 *             OfficerIDs considering permission levels of 
 *             logged in user               
 *
 * Modified By: R.Cole - 11/12/2010 : #1533  Modfied to 
 *                include the TrackerName (S/N) in the
 *                the result set.
 *              S.Florek - 12/15/2010: Revised for Performance
 *              SABBASI - 06/02/2011; Added PartNumber details for Task #2351 
 *				SABBASI - 11/27/2014; Added DeviceType property of Gateway.Devices table in the resultset. Task # 6975
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetDetailsByAgnIDOfcID] (
	  @AgencyIDs VARCHAR(MAX),  
    @OfficerIDs VARCHAR(MAX),   
    @UserID INT  
)
AS
BEGIN
  SET NOCOUNT ON;
  
  -- Declare variable according to rights IDs.
  DECLARE @Agn_ViewAll INT, 
          @Agn_ViewAssociated INT ,
          @Agn_ViewUserSpecific INT, 
          @Agn_TAM INT, 
          @Agn_ViewNone INT

  SET @Agn_ViewAll = 1
  SET @Agn_ViewAssociated = 2
  SET @Agn_ViewUserSpecific = 3
  SET @Agn_TAM = 4;


  --Unpack the officer and agency list parameters
  select number into #tmpofc
  from GetTableFromListId(@OfficerIDs)
  
  --select number into #tmpagn
  --from GetTableFromListId(@AgencyIDs)

  create clustered index #xpktmpofc on #tmpofc(number);
  --create clustered index #xpktmpagn on #tmpagn(number)

  WITH UserRights AS
  (
	  SELECT RightID FROM Role_Rights WHERE RoleID IN
	  (
		  SELECT  ur.RoleID
		  FROM [User] (NOLOCK)
		    INNER JOIN User_Role ur ON  ur.UserID = [User].UserID
		  WHERE [User].UserID = @UserID
	  )
  )SELECT * INTO #tempT FROM UserRights

  --	Make sure that the user role does not have View Associated Agencies permission
  IF NOT EXISTS(SELECT 1 FROM #tempT WHERE RightID = @Agn_ViewAssociated)
    BEGIN      
      SELECT DISTINCT Offender.OffenderID ,  
             ISNULL(Offender.LastName, '') + ', '+ ISNULL(Offender.FirstName, '') AS 'OffenderName',  
             Offender.AgencyID,  
             Offender_Officer.OfficerID,  
             ISNULL(Officer.LastName, '')  + ', ' + ISNULL(Officer.MiddleName, '') + ' ' +  ISNULL(Officer.FirstName, '') AS 'OfficerName',    
             Agency.Agency,  
             ISNULL(TrackerAssignment.TrackerID,0) AS TrackerID,   
             ISNULL(Tracker.TrackerNumber,0) AS TrackerNumber,
             Tracker.TrackerName,
       			 ISNULL(Tracker.PartNumber, 0) + ' ' + ISNULL(PartNumberDetail.Description, '') AS PartNumber,
			 d.DeviceType 
      FROM Offender (NOLOCK)         
        LEFT JOIN Offender_Officer (NOLOCK) ON Offender.OffenderID = Offender_Officer.OffenderID 
        INNER JOIN Agency (NOLOCK) ON Offender.AgencyID = Agency.AgencyID             
        INNER JOIN Officer (NOLOCK) ON Officer.OfficerID = Offender_Officer.Officerid   --LEFT JOIN
        INNER JOIN TrackerAssignment (NOLOCK) ON TrackerAssignment.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID)   
                                                                                 FROM [TrackerAssignment] (NOLOCK) ta   
                                                                                 WHERE ta.OffenderID = Offender.OffenderID   
                                                                                   AND ta.TrackerAssignmentTypeID = 1)   
        LEFT JOIN Tracker (NOLOCK) ON Tracker.TrackerID = TrackerAssignment.TrackerID
		INNER JOIN Gateway.dbo.Devices d ON d.DeviceID = Tracker.TrackerID
        LEFT JOIN PartNumberDetail ON Tracker.PartNumber LIKE PartNumberDetail.PartNumber           
        INNER JOIN #tmpofc ON Officer.OfficerID = #tmpofc.number
      WHERE 
              
/* This is some old code that should be obsolete but here it is just in case.
                (@Agn_ViewUserSpecific IN (SELECT RightID FROM #tempT)) AND (Offender.AgencyID IN (SELECT number from GetTableFromListId(@AgencyIDs))))        
                OR (Offender_Officer.OfficerID IN (SELECT number from GetTableFromListId(@OfficerIDs))
*/
                
         Offender.Deleted = 0   
         AND Offender.Victim = 0  
         AND Tracker.Deleted =0  
      ORDER BY [OffenderName]    
    END  
  ELSE
    -- When User is a member of role having View associated agencies right.     
    BEGIN     


      SELECT DISTINCT Offender.OffenderID ,  
             DistributorEmployee.UserID,  
             ISNULL(Offender.LastName, '') + ', ' + ISNULL(Offender.FirstName, '') AS 'OffenderName',     
             Offender.AgencyID,  
             Offender_Officer.OfficerID,  
             ISNULL(Officer.LastName, '') + ', ' +  ISNULL(Officer.MiddleName, '') + ' ' +  ISNULL(Officer.FirstName, '') AS 'OfficerName',    
             Agency.Agency,  
             ISNULL(TrackerAssignment.TrackerID,0) AS TrackerID,   
             ISNULL(Tracker.TrackerNumber,0) AS TrackerNumber,
             Tracker.TrackerName, 
			       ISNULL(Tracker.PartNumber, 0) + ' ' + ISNULL(PartNumberDetail.Description, '') AS PartNumber,
			 d.DeviceType
      FROM Offender (NOLOCK)
        INNER JOIN Agency (NOLOCK) ON Agency.AgencyID = Offender.AgencyID      
        INNER JOIN DistributorEmployee (NOLOCK) ON DistributorEmployee.DistributorID = Agency.DistributorID  
               AND DistributorEmployee.UserID = @UserID      
        INNER JOIN Offender_Officer (NOLOCK) ON Offender_Officer.OffenderID = Offender.OffenderID
        INNER JOIN Officer (NOLOCK) ON Officer.OfficerID = Offender_Officer.OfficerID  
        LEFT JOIN TrackerAssignment (NOLOCK) ON TrackerAssignment.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID)   
                                                                                FROM [TrackerAssignment]  (NOLOCK) ta   
                                                                                WHERE ta.OffenderID = Offender.OffenderID   
                                                                                  AND ta.TrackerAssignmentTypeID = 1)   
      LEFT JOIN Tracker (NOLOCK) ON Tracker.TrackerID = TrackerAssignment.TrackerID
	  INNER JOIN Gateway.dbo.Devices d ON d.DeviceID = Tracker.TrackerID
   	  LEFT JOIN PartNumberDetail ON Tracker.PartNumber LIKE PartNumberDetail.PartNumber       
      INNER JOIN #tmpofc ON Officer.OfficerID = #tmpofc.number
      WHERE 
	  --We already checked this
      --(@Agn_ViewAssociated IN (SELECT RightID FROM #tempT))
        Offender.Deleted = 0   
        AND Offender.Victim = 0
        AND Tracker.Deleted =0      
      ORDER BY [OffenderName]  
    END  
  --EndIF  
END

USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OffenderGetAllDetailsByAgencyIDOfficerID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OffenderGetAllDetailsByAgencyIDOfficerID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   OffenderGetAllDetailsByAgencyIDOfficerID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     
 * Purpose:                   
 *
 * Modified By: R.Cole - 11/12/2010: #1533 - Modified to 
 *                return the TrackerName (S/N) in the results.
 *                Cleaned up the WHERE clauses for readability.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[OffenderGetAllDetailsByAgencyIDOfficerID] (  
    @AgencyID INT,  
    @OfficerID INT,   
    @RoleID INT,   
    @UserID INT = -1  
)  
AS  
  
IF @RoleID <> 6      
  BEGIN      
    SELECT DISTINCT Offender.OffenderID ,  
           ISNULL(Offender.LastName, '') + ', '+ ISNULL(Offender.FirstName, '') AS 'OffenderName',  
           Offender.AgencyID,  
           Offender_Officer.OfficerID,  
           ISNULL(Officer.LastName, '')  + ', ' + ISNULL(Officer.MiddleName, '') + ' ' +  ISNULL(Officer.FirstName, '') AS 'OfficerName',    
           Agency.Agency,  
           ISNULL(TrackerAssignment.TrackerID,0) AS TrackerID,   
           ISNULL(Tracker.TrackerNumber,0) AS TrackerNumber,
           Tracker.TrackerName  
    FROM Offender          
      LEFT JOIN Offender_Officer  ON Offender.OffenderID = Offender_Officer.OffenderID       
      INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID             
      INNER JOIN Officer ON Officer.OfficerID = Offender_Officer.Officerid   --LEFT JOIN
      LEFT JOIN TrackerAssignment ON TrackerAssignment.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID)   
                                                                              FROM [TrackerAssignment] ta   
                                                                              WHERE ta.OffenderID = Offender.OffenderID   
                                                                                AND ta.TrackerAssignmentTypeID = 1)   
      LEFT JOIN Tracker ON Tracker.TrackerID = TrackerAssignment.TrackerID  
    WHERE (  
            ( (@RoleID = 2 OR @RoleID = 3) AND (Offender.AgencyID = @AgencyID) )        
          OR   
            ( ((@AgencyID <= 0) OR (Offender.AgencyID = @AgencyID)) AND ((@OfficerID <= 0) OR (Offender_Officer.OfficerID = @OfficerID)))  
          )              
      AND Offender.Deleted = 0   
      AND Offender.Victim = 0 
      AND (TrackerAssignment.TrackerID IS NULL OR Tracker.Deleted = 0)         
    ORDER BY [OffenderName]    
  END    
ELSE   
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
           Tracker.TrackerName   
    FROM Offender   
      INNER JOIN Agency ON Agency.AgencyID = Offender.AgencyID      
      INNER JOIN DistributorEmployee ON DistributorEmployee.DistributorID = Agency.DistributorID  
             AND DistributorEmployee.UserID = @UserID      
      INNER JOIN Offender_Officer ON Offender_Officer.OffenderID = Offender.OffenderID       --LEFT JOIN
      INNER JOIN Officer ON Officer.OfficerID = Offender_Officer.OfficerID  
      LEFT JOIN TrackerAssignment ON TrackerAssignment.TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID)   
                                                                              FROM [TrackerAssignment] ta   
                                                                              WHERE ta.OffenderID = Offender.OffenderID   
                                                                                AND ta.TrackerAssignmentTypeID = 1)   
      LEFT JOIN Tracker ON Tracker.TrackerID = TrackerAssignment.TrackerID   
    WHERE (@RoleID = 6 OR @RoleID = 20)        
      AND Offender_Officer.OfficerID = @OfficerID   
      AND (TrackerAssignment.TrackerID IS NULL OR Offender.Deleted = 0)
      AND Offender.Victim = 0
      AND Tracker.Deleted =0      
    ORDER BY [OffenderName]  
  END  
--EndIF  
GO

GRANT EXECUTE ON [dbo].[OffenderGetAllDetailsByAgencyIDOfficerID] TO db_dml;
GO
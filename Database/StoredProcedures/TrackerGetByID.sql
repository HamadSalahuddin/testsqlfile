USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[TrackerGetByID]    Script Date: 04/06/2010 14:26:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  ALTER PROCEDURE [dbo].[TrackerGetByID]  
  
 @TrackerID INT = -1,  
 @TrackerUniqueId int=-1,  
 @GetDeleted BIT = 0  
  
AS  
  
 SELECT  
  t.TrackerUniqueID,  
  ISNULL(ta.OffenderID,0) AS offenderID,   
  t.TrackerID,   
  t.TrackerNumber,   
  ISNULL(t.TrackerName,'')+' '+CAST(t.TrackerNumber AS VARCHAR(50)) AS "TrackerName",
  t.AgencyID,   
  a.Agency,   
  t.IsDemo,   
  t.BillableID,   
  t.CreatedDate,  
  t.CreatedByID,  
  t.ModifiedDate,  
  t.ModifiedByID,  
  tb.AuthorizedByID,   
  opr.LastName + ', ' + opr.FirstName AS 'AuthorizedByName',  
  tb.InvoiceNumber,  
  tb.Status AS 'Billable',  
  t.Deleted  
 FROM   
  Tracker t  
  LEFT JOIN TrackerAssignment ta ON ta.TrackerID = t.TrackerID  
   AND ta.AssignmentDate = (SELECT MAX(AssignmentDate) FROM TrackerAssignment ta WHERE ta.TrackerID = t.TrackerID)  
  LEFT JOIN Agency a ON t.AgencyID = a.AgencyID  
  LEFT JOIN TrackerBillable tb ON tb.TrackerBillableID = t.BillableID  
  LEFT JOIN Operator opr ON opr.UserID = tb.AuthorizedByID  
--  LEFT JOIN TrackerBillable tb ON tb.TrackerID = t.TrackerID  
--   AND tb.AuthorizedDate = (SELECT MAX(AuthorizedDate) FROM TrackerBillable tb WHERE tb.TrackerID = t.TrackerID)  
 WHERE  
  (  
   (@TrackerID<0 )  
   or  
   (t.TrackerID = @TrackerID )  
  )  
   and  
  (  
   (@TrackerUniqueId<0)  
    or   
   (@TrackerUniqueId=t.TrackerUniqueID)  
  )  
  
  AND (@GetDeleted = 1 OR t.Deleted = 0)
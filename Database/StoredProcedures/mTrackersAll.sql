USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mTrackersAll]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mTrackersAll]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* *************************************************************
 * FileName:   mTrackersAll.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: S.Abassi - 02/11/2010: Added TrackerName Field
 *              R.Cole - 02/11/2010: Added IF EXISTS AND 
 *              GRANT statements
 * Modified By: S.Abbasi - 01/05/2011
 *                Added PartNumber field for Task #1790
 * ************************************************************ */
CREATE PROCEDURE [dbo].[mTrackersAll]
AS
BEGIN
  SELECT t.TrackerID, 
         t.TrackerUniqueID, 
         t.TrackerNumber, 
         t.TrackerName,
         ISNULL(t.PartNumber,'') AS 'PartNumber',
	       t.AgencyID,
	       t.CreatedDate, 
         t.CreatedByID, 
         t.ModifiedDate, 
         t.ModifiedByID,
	       t.Deleted, 
         t.IsDemo,
	       t.BillableID, 
         CASE WHEN tb.Status = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS 'IsBillable',
	       tb.CreatedByID AS 'Billable CreatedByID', 
         tb.CreatedDate AS 'Billable CreatedDate',
	       tb.AuthorizedByID AS 'Billable AuthorizedByID', 
         tb.InvoiceNumber AS 'Billable InvoiceNumber',
	       tr.RmaID, 
         tr.CreatedByID AS 'RMA CreatedByID', 
         tr.CreatedDate AS 'RMA CreatedDate',
	       tr.TrackerRMAReasonID AS 'RMA ReasonID', 
         tr.ReasonText AS 'RMA ReasonText',
         tv.ID AS 'VersionID', 
         tv.VersionName AS 'VersionName'
  FROM Tracker t 
	  LEFT JOIN TrackerBillable tb ON t.BillableID = tb.TrackerBillableID
	  LEFT JOIN TrackerRma tr ON t.RmaID = tr.RmaID AND tr.RemovedDate IS NULL
    LEFT JOIN TrackerVersion tv ON t.TrackerVersion = tv.ID
  WHERE Deleted = 0
END
GO

GRANT EXECUTE ON [dbo].[mTrackersAll] TO db_dml;
GO
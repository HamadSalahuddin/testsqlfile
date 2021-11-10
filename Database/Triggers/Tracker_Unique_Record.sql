USE TrackerPAL
GO

IF OBJECT_ID ('Tracker_Unique_Record', 'TR') IS NOT NULL
  DROP TRIGGER Tracker_Unique_Record;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* *************************************************************
 * FileName:   Tracker_Unique_Record.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc  
 * Task #:		 N/A      
 * Purpose:    Ensure there is only one active Tracker record
 *             per OTD
 *
 * Modified By: R.Cole - 02/11/2010: Updated Trigger with new
 *              TrackerName field
 * *********************************************************** */
CREATE TRIGGER dbo.Tracker_Unique_Record
  ON dbo.Tracker
  INSTEAD OF INSERT
AS 
BEGIN
  DECLARE @TrackerID INT
  SET @TrackerID = (SELECT TrackerID FROM inserted)
   
  PRINT CONVERT( VARCHAR, @TrackerID )

  IF ((SELECT COUNT(t.TrackerID) 
       FROM Tracker t 
       WHERE Deleted = 0 
         AND t.TrackerID = @TrackerID) > 0)
    BEGIN
	    RAISERROR( 'Tracker already assigned.', 16, 13 )
    END
  ELSE
    BEGIN
	    INSERT INTO TrackerPal.dbo.Tracker (
        TrackerID,
        TrackerNumber,
        AgencyID,
        CreatedDate,
        CreatedByID,
        ModifiedDate,
        ModifiedByID,
        Deleted,
        RmaID,
        IsDemo,
        BillableID,
        TrackerVersion,
        TrackerName
      )
		  SELECT TrackerID,
             TrackerNumber,
             AgencyID,
             CreatedDate,
             CreatedByID,
             ModifiedDate,
             ModifiedByID,
             Deleted,
             RmaID,
             IsDemo,             
             BillableID,
	           TrackerVersion,
             TrackerName
		  FROM inserted 
	  END --INSERT
  --IF
END --TRIGGER
GO

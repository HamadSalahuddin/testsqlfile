USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[DaylightProgressAddEArrest]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DaylightProgressAddEArrest]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   DaylightProgressAddEArrest.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     <Redmine #>      
 * Purpose:                   
 *
 * Modified By: S.Abbasi - 03/12/10
 * ******************************************************** */
CREATE PROCEDURE [dbo].[DaylightProgressAddEArrest]  
  
 @DaylightUpdateID   INT OUTPUT,  
 @TrackerID      INT,  
 @OffenderID         INT  
   
  
AS   
DECLARE @NewTrackerID int 
-- Check if the tracker id already exist
SELECT @NewTrackerID = TrackerID 
FROM DaylightUpdateProgress  
WHERE TrackerID =  @TrackerID  
IF @NewTrackerID = NULL 
BEGIN
 INSERT INTO DaylightUpdateProgressEArrest  
     (TrackerID, OffenderID)  
 VALUES  
     (@TrackerID, @OffenderID)   
 SET @DaylightUpdateID = @@IDENTITY  
END

ELSE    
SET @DaylightUpdateID = -1
GO

GRANT EXECUTE ON [dbo].[DaylightProgressAddEArrest] TO db_dml;
GO 

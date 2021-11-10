/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ERuleAdd]  
 @ID                  INT OUTPUT,  
 @Name                NVARCHAR(50),  
 @BeaconID            INT,  
 @TrackerID  INT,  
 @CreatedUserID      INT  
      
AS  
DECLARE @RuleID INT  
BEGIN  
BEGIN TRANSACTION   
    INSERT INTO [Rule]  
 (CreatedByID)  
 VALUES  
 (@CreatedUserID)  
  
SET @RuleID = @@IDENTITY  

DECLARE @TrackeruniqueID   INT
SET @TrackeruniqueID=0
SELECT @TrackeruniqueID = trackeruniqueid 
FROM tracker 
WHERE trackerid=@TrackerID

DECLARE @AssignedETrackerID   INT
SET @AssignedETrackerID=0
SELECT @AssignedETrackerID = etrackerid 
FROM etracker 
WHERE trackerid=@TrackeruniqueID

IF(@AssignedETrackerID=0 )
BEGIN
INSERT INTO etracker (trackerid) values(@TrackeruniqueID)
SET @AssignedETrackerID=@@IDENTITY
END


 INSERT INTO dbo.ERule  
 ([Name],BeaconID,RuleID,AssignedETrackerID)  
 VALUES  
 (@Name,@BeaconID,@RuleID,@AssignedETrackerID)  
  
 SET @ID = @@IDENTITY  
COMMIT TRANSACTION  
END  


GO
GRANT EXECUTE ON [ERuleAdd] TO [db_dml]
GO

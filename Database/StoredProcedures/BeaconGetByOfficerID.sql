/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [BeaconGetByOfficerID]

@OfficerID INT

AS

	SET NOCOUNT ON
DECLARE
@TempTable
TABLE 
(
ID int,
beaconName nvarchar(50),
Identifier nvarchar(50)
)

INSERT INTO 
@TempTable 
(
ID,
beaconName,
Identifier
)
	 SELECT distinct b.ID,b.BeaconName as 'Name', b.identifier
            
	 FROM Beacon b  
 inner join BeaconOffender bo ON b.ID = bo.Beaconid 
 inner join Offender_Officer o ON o.OffenderID=bo.OffenderID
   
    WHERE o.OfficerID=@OfficerID AND b.deleted = 0
ORDER BY b.BeaconName  

delete from @TempTable where ID >
(
  Select min(ID) from @TempTable Tbl1 
  where [@TempTable].identifier = Tbl1.identifier
)

Select * from @TempTable




GO
GRANT EXECUTE ON [BeaconGetByOfficerID] TO [db_dml]
GO
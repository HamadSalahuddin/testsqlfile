/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spOffendersGetAll]

As 
Select 
o.Offenderid
,o.FirstName+' '+o.LastName as 'OffenderName'
From Offender o
Where o.FirstName IS NOT NULL
ORDER BY o.FirstName

GO
GRANT EXECUTE ON [spOffendersGetAll] TO [db_dml]
GO

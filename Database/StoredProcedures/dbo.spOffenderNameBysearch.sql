/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:28 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spOffenderNameBysearch]


@OffenderName varchar(64) = NULL
AS
SELECT  

o.FirstName+' '+o.LastName AS 'OffenderName'
From Offender o
Where (o.FirstName+o.LastName LIKE '%' + ISNULL(@OffenderName,'') + '%')
GO
GRANT EXECUTE ON [spOffenderNameBysearch] TO [db_dml]
GO
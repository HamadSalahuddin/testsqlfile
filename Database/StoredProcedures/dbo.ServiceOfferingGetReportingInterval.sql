/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ServiceOfferingGetReportingInterval]
AS  
SELECT *  
FROM refServiceOptionReportingInterval 
Order By DisplayOrder 


GO
GRANT EXECUTE ON [ServiceOfferingGetReportingInterval] TO [db_dml]
GO
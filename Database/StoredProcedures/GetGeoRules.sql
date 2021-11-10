/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GetGeoRules]
As
BEGIN
Select
GeoruleName
,Georuleid
From Georule
Order By GeoruleName
END
 
GO
GRANT EXECUTE ON [GetGeoRules] TO [db_dml]
GO

/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoruleAllocateUnusedRules]

@rules INT,
@Agencyid INT

AS

BEGIN
UPdate Georule_Agency Set Agencyid = @Agencyid Where Georuleid IN 
(Select TOP(@rules) ga.Georuleid From Georule_Agency ga
JOIN Georule gr ON gr.georuleid = ga.georuleid 
Where gr.georulename ='UNUSED' AND ga.agencyid = 750) 
END


GO
GRANT EXECUTE ON [GeoruleAllocateUnusedRules] TO [db_dml]
GO

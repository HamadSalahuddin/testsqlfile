/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mOffendersAll]

AS

SELECT o.OffenderID, AgencyID, oo.OfficerID, FirstName, MiddleName, LastName, BirthDate,o.RiskLevelID,o.OffenderPay
FROM Offender o JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
WHERE o.Deleted = 0 AND Victim = 0
GO
GRANT EXECUTE ON [mOffendersAll] TO [db_dml]
GO
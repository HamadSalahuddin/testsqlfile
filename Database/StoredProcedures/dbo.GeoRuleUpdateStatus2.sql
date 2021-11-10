/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
/* ///////////////////////////////////////////////////// --
-- // FileName:     GeoRuleUdateStatus.sql            // -- 
-- // Created On:	                                  // --
-- // Created By:   K.Griffiths                       // --
-- // Task #:		SA_                               // --
-- // Purpose:                                        // --
-- //                                                 // --
-- //                                                 // --
-- // Modified By:  <Name> - <Date>                   // --
-- ///////////////////////////////////////////////////// */

CREATE PROCEDURE [GeoRuleUpdateStatus2] (
    @GeoRuleID INT
)
AS
UPDATE GEORULE 
    SET STATUSID = 4,
        UPDATEINPROGRESS = 1
WHERE GEORULEID = @GeoRuleID

GO
GRANT EXECUTE ON [GeoRuleUpdateStatus2] TO [db_dml]
GO
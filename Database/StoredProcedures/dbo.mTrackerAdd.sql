/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mTrackerAdd]

       
        @TrackerID              INT,
        @TrackerNumber  VARCHAR(32),
        @AgencyID               INT,
        @CreatedByID    INT,
        @IsDemo                 bit,
        @FirmwareVersion INT,        
        @TrackerUniqueID INT = NULL OUTPUT

AS

--DECLARE @RmaID int
--SET @RmaID = (
--        SELECT TOP 1 RmaID
--        FROM Tracker
--        WHERE
--                TrackerID = @TrackerID
--                AND TrackerNumber = @TrackerNumber
--                AND CreatedDate = (
--                        SELECT MAX(CreatedDate)
--                        FROM Tracker
--                        WHERE TrackerNumber = @TrackerNumber AND TrackerNumber = @TrackerNumber
--                )
--)

        INSERT INTO Tracker
        (TrackerID, TrackerNumber, AgencyID, CreatedByID, RmaID, isDemo, TrackerVersion)
        VALUES
        (@TrackerID, @TrackerNumber, @AgencyID, @CreatedByID, NULL, @IsDemo, @FirmwareVersion)

        SET @TrackerUniqueID = @@IDENTITY


GO
GRANT EXECUTE ON [mTrackerAdd] TO [db_dml]
GO

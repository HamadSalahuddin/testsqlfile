/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetDefaultImage]
@iOffenderID INT

AS
BEGIN
SELECT * 
FROM OffenderImage 
WHERE OffenderID = @iOffenderID AND DefaultImage = 1
            
END

GO
GRANT EXECUTE ON [OffenderGetDefaultImage] TO [db_dml]
GO
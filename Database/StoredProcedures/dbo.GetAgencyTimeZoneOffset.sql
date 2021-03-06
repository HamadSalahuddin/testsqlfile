/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GetAgencyTimeZoneOffset] (
  @AgencyID INT
) 
AS
SET NOCOUNT ON;

-- // Declare Var // --
DECLARE @Today AS DATETIME
SET @Today = GETUTCDATE()

-- // Get the Timezone Offset in minutes for the Agency // --
SELECT TimeZoneOffset = (SELECT TOP 1 CASE WHEN Agency.DaylightSavings IS NOT NULL 
				                                    AND Agency.DaylightSavings > 0 
				                                    AND DATEADD(mi,TimeZone.UtcOffset,@Today) >= (SELECT Start FROM DaylightSaving WHERE [Year] = YEAR( @Today)) 
				                                    AND DATEADD(mi,TimeZone.UtcOffset,@Today) <= (SELECT [End] FROM DaylightSaving WHERE [Year] = YEAR( @Today)) 
			                                     THEN TimeZone.DaylightUtcOffset
			                                     ELSE TimeZone.UtcOffset
		                                  END
                         FROM TimeZone
                           LEFT JOIN Agency ON Agency.TimeZoneID = TimeZone.TimeZoneID 
                                 AND Agency.AgencyID = @AgencyID
                         WHERE AgencyID = @AgencyID
                        )

GO
GRANT EXECUTE ON [GetAgencyTimeZoneOffset] TO [db_dml]
GO

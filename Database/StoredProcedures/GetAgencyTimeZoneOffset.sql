USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GetAgencyTimeZoneOffset]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].GetAgencyTimeZoneOffset
GO

USE TrackerPal
GO

/* **********************************************************
 * FileName:   GetAgencyTimeZoneOffset.sql
 * Created On: 01/12/2010         
 * Created By: R.Cole
 * Task #:		 <Redmine #>      
 * Purpose:    Given then AgencyID, Returns the current
 *             TimeZone Offset in minutes from UTC, accounts 
 *             accounts for Daylight Savings changes.               
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE GetAgencyTimeZoneOffset (
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

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].GetAgencyTimeZoneOffset TO db_dml;
GO
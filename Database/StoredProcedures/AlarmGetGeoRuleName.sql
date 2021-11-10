USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[AlarmGetGeoRuleName]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AlarmGetGeoRuleName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* *************************************************************
 * FileName:   AlarmGetGeoRuleName.sql
 * Created On: 02/22/2010         
 * Created By: R.Cole  
 * Task #:     SA_114      
 * Purpose:    Lookup GeoRuleNames for Alarms being handled
 *             by the AutoMC system.  Returns an empty string
 *             if the EventTypeID does not pertain to GeoRules
 *
 * Modified By: <Name> - <DateTime>
 * *********************************************************** */
CREATE PROCEDURE [dbo].[AlarmGetGeoRuleName] (
  @AlarmID INT,
  @OffenderID INT,
  @GeoRuleName VARCHAR(200) OUTPUT
)
AS
SET NOCOUNT ON;
  
DECLARE @EventTypeID INT,
        @EventParameter BIGINT  

-- // Get the EventType and EventParam // --
SELECT @EventTypeID = ISNULL(EventTypeID, 0),
			 @EventParameter = ISNULL(EventParameter, 0)
FROM	Alarm
WHERE	AlarmID = @AlarmID

-- // Get the GeoRule Name // -- 
IF @EventTypeID IN (32,33,36,37,40,41,44,45)
  BEGIN                        
    SELECT @GeoRuleName = GeoRule.GeoRuleName
    FROM GeoRule_Offender
      INNER JOIN GeoRule ON GeoRule.GeoRuleID = GeoRule_Offender.GeoRuleID
    WHERE GeoRule_Offender.OffenderID = @OffenderID 
      AND GeoRule_Offender.ZoneID = @EventParameter
  END
ELSE
  SELECT @GeoRuleName = ''
GO

-- // Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[AlarmGetGeoRuleName] TO db_dml;
GO